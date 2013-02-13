module TFLog

  # This parses a line given to it.  *This should only be used as the parent of
  # a child class.*  On its own, it will not parse anything.  Checkout the
  # Parsers module for parses for the line.
  class LineParser

    # The data taken out of the line.
    attr_accessor :data
    

    def initialize(line)
      @line = line
      @data = {}
      @stopped = false
    end

    # Parse the line.
    def parse!
      set :line => @line
      instance_exec(&self.class.get_parsable)
      self
    end

    # A convinence method for subclasses to put their parsing logic in.
    def self.build(&block)
      @block = block
    end

    # Get the block that was given by the subclass.
    def self.get_parsable
      @block || Block.new
    end

    # FOR PARSING

    # Can accept a Hash or a regular expression.  If it's a regular expression,
    # it matches to the line (and if it does match, it yields).  If it's a hash,
    # it'll match the first key-value pair; if they match, it'll yield, or if no
    # block is given, #set the reset of the key-value pairs of the hash.  If
    # `stop` is the key and `true` is the value, it calls #stop.
    #
    #   on %r{\A\*} => line, :type => :comment, :stop => true
    def on(match, data = nil)
      return if stopped?
      
      if data.is_a? Hash
        pairs = [[ match, @line ]] + data.to_a
      else
        # we're assuming that data is nil.
        if match.is_a? Hash
          pairs = match.to_a
        else
          pairs = [[ match, @line ]]
        end
      end

      pairs = pairs.to_a
      condition = pairs.shift

      if m = condition[1].match(condition[0])
        match_data = MethodAccessor.new(m)
        if block_given?
          yield match_data
        else
          pairs.each do |k, v|
            next stop if k == :stop and v
            set k, format(v, match_data)
          end
        end
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

    # Gets a value from a given key.  A convience method for data[name].
    def get(name)
      data[name]
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

    # Tell #on that we want the value from the match to be replaced here.  Give
    # it the #d!
    def d(name)
      DataAccessor.new(name)
    end

    def format(value, match)
      return value unless value.is_a? DataAccessor
      return match.get value.name
    end

    def method_missing(method, *args)
      super if args.length > 1 or block_given?
      if args.length == 0
        get method
      else
        set method, args[0]
      end
    end


    class DataAccessor < Struct.new(:name); end

  end
end