module TFLog

  # Allows access to a Hash through method calls.
  class MethodAccessor
    
    def initialize(hash)
      @hash = hash
    end

    # Provides easy access to the hash.
    def [](name)
      @hash[name]
    end

    # Gets the value +name+ from the hash.
    def get(name)
      self[name] || self[name.to_s] || self[name.intern]
    end

    # Sets the name, value pair.
    def []=(name, value)
      @hash[name] = value
    end

    # Sets the name, value pair, checking for different keys.
    def set(name, value)
      key = name
      if self[key]
        self[key] = value
      elsif self[key.to_s]
        self[key.to_s] = value
      elsif self[key.intern]
        self[key.intern] = value
      else
        self[name] = value
      end
    end

    # Returns the value of the attribute in question.  If the method ends in a
    # question mark, and arguments are passed, it checks the value of the
    # attribute against the arguments provided and if any of them match it
    # returns true.  If an argument is given with no question mark, then the
    # attribute is set to that argument.
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
    def respond_to_missing?(method)
      (self[method] or self[method.to_s]) and true
    end
  end
end