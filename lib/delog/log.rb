module Delog

  # This is the log.  You use `Log.new(log)` to create a new log, and #each
  # should give you each line of the log (a Line class).
  class Log

    extend Forwardable
    include Enumerable
    
    # The default options that are merged with the user options, as in if the
    # user didn't define it, it's set to the default.
    DEFAULT_OPTIONS = {
      :parser => Parsers::Basic
    }

    # The options, as passed by the user.  Is a hash, and is not frozen.  Not
    # used until the line set is created.
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

    # Refresh the line set.  This may be caused by a new modification to the
    # file.
    def refresh!
      @lines = load_from_file
    end

    # Enumerate over the lines.  This uses a handy thing with def_delegator that
    # makes it call #to_set in order for it to delegate it to something; this
    # allows us to perform the lazy loading of the lines without doing some
    # funky things.
    def_delegator :to_set, :each

    # Pretty inspect.
    def inspect
      path = @log.path rescue ""
      "#<TFLog::Log #{path}>"
    end

    private

    # Load the lines from the file.  The lines are put in a SortedSet.  Each
    # line in the Set is an instance of Line; luckily, Line performs lazy
    # loading of itself so parsing every line does not occur in this method
    # (just the reading of the file into memory).
    def load_from_file
      lines = SortedSet.new
      
      @log.lines.each_with_index do |line, number|
        lines << Line.new(line, number, options)
      end

      lines
    end

  end
end
