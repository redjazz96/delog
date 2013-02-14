require 'delog/line_parser/context'
require 'delog/line_parser/behaviour'

module Delog

  # This parses a line given to it.  *This should only be used as the parent of
  # a child class.*  On its own, it will not parse anything.  Checkout the
  # Parsers module for parses for the line.
  class LineParser

    include Behaviour

    # The options, as passed to by Line.  The options are frozen by Line, so
    # don't try modifying them!  They're provided in this class so that parsers
    # can change behaviour based on these options, which are completely user
    # defined.
    attr_reader :options

    # The context the parser will run under.  This should be a Context.
    attr_reader :context
    
    # Initialize the class.
    def initialize(line, options = {})
      @line = line
      @context = Context.new
      setup_context
      super()
    end

    # Parse the line.  Uses ::get_parsable, which is called in the context of
    # the instance of the class.  Returns the instance of the class.
    def parse!
      set :line => @line
      @context.run(&self.class.get_parsable)
      self
    end

    private

    # Returns +value+ unless it's a DataAccessor.  If it is, though, it
    # returns the value for the data (or nil, if it doesn't exist).
    def format(value, match)
      return value unless value.is_a? DataAccessor
      return match.get value.name
    end

    # Adds the whitelisted methods to the context.  Calls #add_method on the
    # context, adding a user-defined whitelist with a list of methods for this
    # class.  Check out ::def_whitelist or ::get_whitelist
    def setup_context
      context_methods.each do |m|
        @context.add_method m, self
      end
    end

    # Adds some local methods to the context methods.
    def context_methods
      super + [:context]
    end

    # This is used to represent a matchdata value.  This is mainly used for the
    # short hand <tt>on /regex/, :something => d(:somedata)</tt>.
    class DataAccessor < Struct.new(:name); end

  end
end
