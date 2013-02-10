module TFLog

  # This is the log.  You use `Log.new(log)` to create a new log, and #each
  # should give you each line of the log (a Line class).
  class Log

    extend Forwardable
    include Enumerable
    

    DEFAULT_OPTIONS = {
      :parser => TFLog::Parsers::Basic
    }

    attr_accessor :options
    attr_accessor :log

    # This initializes the log.  It can accept a string and will use that as the
    # path to the file, or it can take any object that can respond to #lines.
    def initialize(log, options = {})
      @options = options.dup.merge DEFAULT_OPTIONS

      if log.is_a? String
        # This means that the log is a path to the file.  We'll try to open it.
        raise FileError unless @log = File.open(log, "r")
      else
        if log.respond_to?(:lines)
          @log = log
        else
          raise FileError
        end
      end
    end

    # This class is the enumerator, so you'd want this class.  If you want
    # direct access to the lines set, try #to_set.  This is just here to
    # pretty things up; `log.lines.first` looks better than `log.first`.
    def lines
      self
    end

    # Give the lines as a set.
    def to_set
      @lines ||= load_from_file
    end

    # Enumerate over the lines.
    def_delegator :to_set, :each

    def inspect
      path = @log.path rescue ""
      "#<TFLog::Log #{path}>"
    end

    private

    def load_from_file
      lines = SortedSet.new
      
      @log.lines.each_with_index do |line, number|
        lines << Line.new(line, number, options)
      end

      lines
    end

  end
end
