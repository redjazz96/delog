require 'forwardable'

module TFLog

  # This is the log.  You use `Log.new(log)` to create a new log, and #each
  # should give you each line of the log (a Line class).
  class Log

    extend Forwardable
    include Enumerable
    

    DEFAULT_OPTIONS = {
      :lazy_load => true
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
        if log.respond_to?(:gets) and log.respond_to?(:lines)
          @log = log
        else
          raise FileError
        end
      end
    end

    # Get the log's lines.
    def lines
      @lines ||= load_from_file
    end

    # Turn the log into a set.
    def to_set
      lines
    end

    # Enumerate over the lines.
    def_delegator :lines, :each

    private

    def load_from_file
      lines = Set.new
      
      log.lines.each do |line|
        Line.new(line, self)
      end

      lines
    end

  end
end