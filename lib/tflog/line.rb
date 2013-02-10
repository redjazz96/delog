module TFLog
  class Line < MethodAccessor

    attr_accessor :line
    attr_accessor :options
    
    def initialize(line, options)
      @line = line
      @options = options
    end

    def data
      @data ||= load_from_line
    end

    def [](name)
      data[name]
    end

    private

    def load_from_line
      parser = options[:parser].new(@line)
      parser.parse!
      parser.data
    end

  end
end