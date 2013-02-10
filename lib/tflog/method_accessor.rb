module TFLog

  # Allows access to a Hash through method calls.
  class MethodAccessor
    
    def initialize(hash)
      @hash = hash
    end

    def [](name)
      @hash[name]
    end

    def method_missing(method, *args)
      if args.length > 0 or block_given?
        return super
      end

      self[method] || self[method.to_s]
    end
  end
end