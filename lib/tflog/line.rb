module TFLog
  class Line < MethodAccessor

    attr_accessor :line
    attr_accessor :options
    attr_accessor :number
    
    def initialize(line, number, options)
      @line = line
      @number = number
      @options = options
    end

    def data
      @data ||= load_from_line
    end

    def [](name)
      data[name]
    end

    # comparison methods

    def <=>(other)
      if other.is_a? self.class
        self.number - other.number
      elsif other
        self.number - other
      end
    end

    def <(other)
      (self <=> other) < 0
    end

    def >(other)
      (self <=> other) > 0
    end

    def eq(other)
      (self <=> other) == 0
    end

    def inspect
      @line.inspect
    end

    private

    def load_from_line
      parser = options[:parser].new(@line)
      parser.parse!
      parser.data
    end

  end
end