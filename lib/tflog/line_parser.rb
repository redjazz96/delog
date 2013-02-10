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

    # When the line matches +match+, it'll yield.  Does nothing if the line was
    # ended.
    def on(match, to = @line)
      return if stopped?

      if m = to.match(match)
        yield MethodAccessor.new(m)
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

  end
end