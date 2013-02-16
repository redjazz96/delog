module Delog
  class LineParser
    module Behaviour
      module ClassMethods
        # A convinence method for subclasses to put their parsing logic in.  This is
        # called with a block, which is then used for parsing (see below for valid
        # method calls).
        def build(&block)
          @block = block
        end

        # Get the block that was given by the subclass.  If the block isn't defined,
        # an empty block is set and returned.
        def get_parsable
          @block ||= Block.new
        end

        # Whitelist a method for use within the block.  This is used for the proxy.
        def def_whitelist(*args)
          get_whitelist.push(*args)
        end

        # Grab the whitelist.  If it's empty, it'll return an empty array.
        def get_whitelist
          @whitelist ||= []
        end

        # Add an addin to the current parser.  This needs to be defined here so
        # that the whitelist can be built (because we can't add methods
        # dynamically to the context that well!).
        def addin(*ads)
          ads.each do |ad|
            addins << Addin.new(ad)
          end
        end

        # Returns all of the addins that the parser requested.  Every element
        # should be an Addin instance.
        def addins
          @addins ||= []
        end
      end

      module InstanceMethods
        # The data taken out of the line.  This is a Hash.
        attr_reader :data

        # This initializes the data, as well as the stop value.
        def initialize
          @data = {}
          @stopped = false
        end

        # Grabs the addins from the class.
        def get_addins
          self.class.addins
        end


        # Grabs the whitelist from the class.
        def get_whitelist
          self.class.get_whitelist
        end

        # Can accept a Hash or a regular expression.  If it's a regular
        # expression, it matches to the line (and if it does match, it yields).
        # If it's a hash, it'll match the first key-value pair; if they match,
        # it'll yield, or if no block is given, #set the reset of the key-value
        # pairs of the hash.  If `stop` is the key and `true` is the value, it
        # calls #stop.
        # If the method is given a regular expression/+{ /regexp/ => match_to }+
        # and a symbol, it'll call the method corresponding to that symbol with
        # the match data if the regular expression matches.
        #
        #   on %r{\A\*} => line, :type => :comment, :stop => true
        def on(match, data = nil, &block)
          return if stopped?
          params = normalize_params match, data, block
          regex, against = params[:match]

          if matched = regex.match(against)
            match_data = MethodAccessor.from_match_data(matched)
            handle_match match_data, params[:data], params[:block]
          end
        end

        # Sets a key-value pair in the tree.  Can accept a hash as the first
        # parameter, or can accept a +name+ key and a +value+ value.
        def set(name, value = nil)
          return if stopped?

          if value and not name.is_a? Hash
            name = { name => value }
          end

          data.merge! name
        end

        # Gets a value from a given key.  A convience method for +data[name]+.
        def get(name)
          data[name]
        end

        # Removes a value from the data.  A convience method for
        # <tt>data.delete(name)</tt>.
        def del(name)
          data.delete(name)
        end

        alias :[] :get

        # End the parsing; the line is finished- no more data can be taken from
        # the line.
        def stop
          @stopped = true
        end

        # If the line has reached the end.
        def stopped?
          @stopped
        end

        # Gives the line.
        def line
          @line
        end

        # Tell #on that we want the value from the match to be replaced here.
        # Give it the #d!
        def d(name)
          DataAccessor.new(name)
        end

        # An easier way to say +get(:key)+ or +set(:key, :value)+ is this;
        # instead, they would be +key+ and +key :value+ respectively.  The
        # latter is the case because an equal sign would denote that +key+ is a
        # local variable.
        def method_missing(method, *args)
          return super if args.length > 1 or block_given?
          if args.length == 0
            return super unless data.has_key?(method)
            get method
          else
            set method, args[0]
          end
        end

        def respond_to_missing?(method, include_private)
          return super if block_given?
          true
        end

        private

        # Handles the match of a line; +match_data+ should be a MethodAccessor,
        # and +pairs+ should be a hash.  If the hash has a key :stop, and the
        # value is trueish, it'll call #stop.  Otherwise, it'll set the key as
        # the value, first calling #format on the value.
        def handle_match(match_data, pairs, block = nil)
          if block
            #block.call match_data, context.current_klass
            context.run_with_current match_data, &block
          else
            pairs.each do |k, v|
              next stop if k == :stop and v
              set k, format(v, match_data)
            end
          end
        end

        # Returns +value+ unless it's a DataAccessor.  If it is, though, it
        # returns the value for the data (or nil, if it doesn't exist).
        def format(value, match)
          return value unless value.is_a? DataAccessor
          return match.get value.name
        end

        # This normalizes the #on variables.  It'll return a hash, with the
        # keys:
        # <tt>:match</tt> :: this is an array; the first element is the actual
        #   matching element, the second element is what it's matched to.
        # <tt>:data</tt>  :: this is a hash that contains data for handle_match.
        #   It can be empty.
        # <tt>:block</tt> :: this is the block that should be called for #on.
        #   It may or may not exist.
        def normalize_params(match, data, block)
          rvalue = { :match => nil, :data => {}, :block => block }

          if data.is_a? Hash
            rvalue[:match] = [match, @line]
            rvalue[:data] = data
          elsif data.is_a? Symbol and not block_given?
            rvalue[:block] = context.current_klass.method(data)
          end

          unless rvalue[:match]
            # we're assuming that data is nil.
            if match.is_a? Hash
              rvalue[:match] = [match.keys[0], match.values[0]]
              match.delete match.keys[0]
              rvalue[:data] = match
            else
              rvalue[:match] = [ match, @line ]
            end
          end

          rvalue
        end

        # This returns an array of methods for #setup_context.
        def context_methods
          get_whitelist + [
            :on, :set, :get, :stop, :stopped?, :method_missing, :data, :d
          ]
        end
      end

      # Extend and include the receiver.
      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
      end
    end
  end
end
