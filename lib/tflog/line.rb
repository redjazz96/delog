module TFLog
  class Line < MethodAccessor

    attr_accessor :line
    attr_accessor :options
    
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

    def <=>(other)
      if other.is_a? Line
        self.number <=> other.number
      else
        self.number <=> other
      end
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