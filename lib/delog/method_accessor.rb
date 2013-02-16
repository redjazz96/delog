module Delog

  # Allows access to a Hash through method calls.  In any method that checks the
  # keys using more than one format, strings are always prioritized over
  # symbols.  This is because creating an unused symbol is expensive.
  class MethodAccessor
    extend Forwardable

    # Initialize the method.
    def initialize(hash = {})
      @hash = hash || {}
    end

    # Creates a new MethodAccessor from a MatchData.  Behaviour with non-named
    # captures may be a bit odd.
    def self.from_match_data(match_data)
      hash = Hash[ match_data.names.zip(match_data.captures) ]
      self.new(hash)
    end

    # Provides easy access to the hash.  Doesn't try to find other key values
    # inside the hash.
    def_delegator :@hash, :[]

    # Gets the value +name+ from the hash.  Checks multiple versions of the
    # key (i.e. itself, string, and symbol, in that order) before giving up and
    # returning nil.  Returns the value if it is found.
    def get(name)
      self[name] || self[name.to_s] || self[name.intern]
    end

    # Sets the name, value pair.  No guessing is done as to whether or not the
    # name should be itself, a string, or a symbol.
    def_delegator :@hash, :[]=

    # Sets the name, value pair.  Checks for already existing elements with the
    # same +key+, but in different formats (i.e. a string, or a symbol, in that
    # order) before setting the +key+ as +value+.
    def set(name, value)
      key = name
      if self[key.to_s]
        self[key.to_s] = value
      elsif self[key.intern]
        self[key.intern] = value
      else
        self[name] = value
      end
    end

    # Checks the keys to see if they match the given key.  Checks different
    # formats of the key to see if it contains it.
    def has_key?(key)
      has_exact_key?(key) or has_exact_key?(key.to_s) or
        has_exact_key?(key.intern)
    end

    # Checks the keys to see if they match the given key.  Does not check
    # different formats (i.e. itself, a string, or a symbol).
    def_delegator :@hash, :has_key?, :has_exact_key?

    # Returns the value of the attribute in question.  If the method ends in a
    # question mark, and arguments are passed, it checks the value of the
    # attribute against the arguments provided and if any of them match it
    # returns true.  If an argument is given with no question mark, then the
    # attribute is set to that argument.
    #
    # We're using +return super+ here because we can't always rely on the parent
    # +method_missing+ raising an error ;)
    def method_missing(method, *args)
      if block_given?
        return super
      end

      method_string = method.to_s

      attribute_value = get(method)

      if args.length > 0

        # It's a question method; the return value should be true or false or
        # nil.
        if method_string =~ /\?\z/
          attribute_name = method_string[0..-2]
          value = get(attribute_name)
          attribute_value = args.include? value
        else
          attribute_value = set(method, args[0])
        end
      end

      attribute_value
    end

    # :nodoc:
    # Uses #has_key? to check if it can respond to it.
    def respond_to_missing?(method)
      has_key? method
    end

    # Pretty inspect.
    def_delegator :@hash, :inspect

  end
end
