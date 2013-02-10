module TFLog
  class Line

    attr_accessor :line
    attr_accessor :log
    
    def initialize(line, log)
      @lineno = line
      @log = log
    end

    private

    def load_from_line

    end

  end
end