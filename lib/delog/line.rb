module Delog

  # A representation of a log's line.  It lazily loads the data from the file,
  # so it's not all loaded at once.
  class Line < MethodAccessor

    # A string containing the line the line is on.  It shouldn't be modified
    # in most cases.
    attr_reader :line

    # The options, as given by the Log class.  Normally frozen (by this class
    # on initialization).
    attr_reader :options

    # The line number the Line is on.  This is mainly used for comparison
    # purposes (since, as a line, a time wouldn't always be guarenteed).  This
    # should always have a value above zero.
    attr_reader :number
    
    def initialize(line, number, options)
      @line = line
      @number = number
      @options = options.dup.freeze
    end

    # The data of the line.  If it's not set, it calls #load_from_line.  This
    # is a Hash, containing the key-value pairs given by a child class of
    # LineParser (which is determined by the options).
    def data
      @data ||= load_from_line
    end

    # Grabs data from #data.  We're able to use def_delegator here because
    # MethodAccessor extends Forwardable.  This is for MethodAccessor, so any
    # calls to this class that is passed to #method_missing (or even #get) are
    # passed to here.
    def_delegator :data, :[]

    # We're overwriting the array setter method with one that raises an error.
    # We don't really want people to modify data since it wouldn't be 
    # reproducable in terms of the line, so we raise a ModificationError.  
    # But if they're really determined, they could just do 
    # <tt>line.data[:key] = :value</tt> instead.
    def []=(name, key)
      raise ModificationError, "Cannot modify a line directly!"
    end

    # comparison methods

    # Compares two objects.  If the other is less than this one, it returns a
    # number greater than 0.  If the other is greater than this one, it returns
    # a number less than 0.  If the other is equal to this one, it returns 0.
    #
    # If the other object is a Line, it uses that Line's #number method to do
    # the comparison.  Otherwise, it uses the entire other object (and this
    # object's number).
    def <=>(other)
      if other.is_a? self.class
        self.number - other.number
      elsif other
        self.number - other
      end
    end

    # If the other method is greater than this method.  A convienience method
    # for #<=>.
    def <(other)
      (self <=> other) < 0
    end

    # If the other method is less than this method.  A convienience method for
    # #<=>.
    def >(other)
      (self <=> other) > 0
    end

    # If the other method is equal to this method.  A convienience method for
    # #<=>.  Also used for #== (an implicit relationship).
    def eq(other)
      (self <=> other) == 0
    end

    # Pretty inspect.
    def_delegator :@line, :inspect

    private

    # Loads the data from the line.  Takes te parser passed by +options+ and
    # creates a new instance, passing in +line+ and +options+, calls +parse!+,
    # and returns +parser.data+.
    def load_from_line
      parser = options[:parser].new(line, options)
      parser.parse!
      parser.data
    end

  end

  # An error when something attempted to modify something that shouldn't be
  # modified.
  class ModificationError < StandardError; end
end