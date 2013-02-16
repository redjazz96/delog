require 'delog/line_parser/addin'
require 'delog/line_parser/behaviour'
require 'delog/line_parser/context'

module Delog

  # This parses a line given to it.  *This should only be used as the parent of
  # a child class.*  On its own, it will not parse anything.  Checkout the
  # Parsers module for parses for the line.
  class LineParser

    include Behaviour

    # The options, as passed to by Line.  The options are frozen by Line, so
    # don't try modifying them!  They're provided in this class so that parsers
    # can change behaviour based on these options, which are completely user
    # defined.
    attr_reader :options

    # The context the parser will run under.  This should be a Context.
    attr_reader :context

    # The included modules.  This is kept track of so that whenever a module is
    # included multiple times, only build is handled more than once.
    attr_reader :addins
    
    # Initialize the class.
    def initialize(line, options = {})
      @line    = line
      @context = Context.new
      @addins  = get_addins
      setup_context
      super()
    end

    # Parse the line.  Uses ::get_parsable, which is called in the context of
    # the instance of the class.  Returns the instance of the class.
    def parse!
      set :line => @line
      @context.run_with_current(&self.class.get_parsable)
      self
    end

    # Add the addins to the context.  This is out here just in case we don't
    # really want to add the addins.
    def handle_addins
      add_addins_to_context
      self
    end

    private

    # Handles the match of a line; +match_data+ should be a MethodAccessor, and
    # +pairs+ should be a hash.  If the hash has a key :stop, and the value is
    # trueish, it'll call #stop.  Otherwise, it'll set the key as the value,
    # first calling #format on the value.
    def handle_match(match_data, pairs, block = nil)
      if block
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

    # Adds the whitelisted methods to the context.  Calls #add_method on the
    # context, adding a user-defined whitelist with a list of methods for this
    # class.  Check out ::def_whitelist or ::get_whitelist.
    def setup_context
      context_methods.each do |m|
        @context.add_method m, self
      end

      @context.define_klass
    end

    # Adds the addins to the context.  Uses #setup_addins to grab data from the
    # addins and then adds the methods to the context and calls the builds in
    # the context to add them.
    def add_addins_to_context
      addin_data = setup_addins addins

      addin_data[:methods].each do |method|
        @context.add_method method[:name], method[:receiver]
      end

      @context.define_klass

      addin_data[:builds].each do |build|
        @context.run_with_current(&build)
      end
    end

    # Sets up the addins passed to the method.  Returns a hash like this:
    #
    #   <tt>:methods</tt> :: the methods to be defined in the context.  It's an
    #     array of hashes, where the hashes have the keys +:receiver+ and
    #     +:name+.
    #   <tt>:builds</tt>  :: the blocks to be executed for the addins.  It's an
    #     array.
    def setup_addins(addins)
      result = { :methods => [], :builds => [] }
      addins.each do |addin|
        result[:methods].concat(addin.whitelist.map do |m|
          { :receiver => addin.addin, :name => m }
        end)

        result[:builds] << addin.build
      end

      result
    end

    # Adds some local methods to the context methods.
    def context_methods
      super + [:context]
    end

    # This normalizes the #on variables.  It'll return a hash, with the keys:
    # <tt>:match</tt> :: this is an array; the first element is the actual
    #   matching element, the second element is what it's matched to.
    # <tt>:data</tt>  :: this is a hash that contains data for handle_match.
    #   It can be empty.
    # <tt>:block</tt> :: this is the block that should be called for #on.  It
    #   may or may not exist.
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

    # This is used to represent a matchdata value.  This is mainly used for the
    # short hand <tt>on /regex/, :something => d(:somedata)</tt>.
    class DataAccessor < Struct.new(:name); end

  end
end