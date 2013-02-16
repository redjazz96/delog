module Delog
  class LineParser
    class Addin

      # The addin name of the addin.  This can only be read, as it'd be hard to
      # change. (Hint: just make another Addin class.)  This is what was passed
      # to #initialize.
      attr_reader :addin_name

      # The module from which the addin should be assumed originated.  If the
      # addin was given as a symbol, this is the module in which it should be
      # located.  Otherwise, this serves no purpose.
      attr_accessor :from_module

      # The actual addin module that is being used.
      attr_reader :addin

      # Initialize.
      def initialize(addin_name, from_module=Delog::Parsers::Addins)
        @addin_name = addin_name
        @from_module = from_module

        resolve_addin
        setup_module
      end

      # Grab the whitelist from the addin.
      def whitelist
        if @addin.respond_to? :whitelist
          @addin.whitelist || []
        else
          []
        end
      end

      # Grab the addin bind for use with the context.  This basically is called
      # in the context, so that the addin can handle its logic.  This is cached.
      # Since the bind is called in Context, any methods that the module wants
      # to use has to be whitelisted.
      def bind
        @_bind ||= bind!
      end

      alias :build :bind

      # This grabs the bind whether or not there is a cached bind.  See #bind.
      # If the module doesn't define a bind, it returns an empty Proc.
      def bind!
        if @adddin.respond_to?(:bind)
          @addin.method(:bind)
        else
          Proc.new { }
        end
      end

      alias :build! :bind!

      private

      # Resolves the addin from a Module or a Symbol/String.  If it's a module,
      # it'll just set the addin as the module and move on.  If it's a symbol,
      # it'll try to turn it from snake_case to CamelCase and then try to
      # retrieve it from the from_module.
      def resolve_addin
        if addin_name.is_a? Symbol
          addin = addin_name.to_s
          unless /\A[A-Z]/ =~ addin
            addin.gsub!(/\_([a-z])/) do |m|
              m[1].upcase
            end

            addin[0] = addin[0].upcase
          end

        else
          addin = addin_name
        end

        @addin = if addin_name.is_a? Module
          addin_name
        else
          from_module.const_get(addin_name)
        end
      end

      # This sets up the module so that any method that doesn't exist on the
      # whitelist will be first checked to see if it is a "instance" method, and
      # if it still doesn't exist it'll raise a NameError.
      def setup_module
        whitelist.each do |method|
          unless addin.respond_to? method
            addin.send :module_function, method

            raise NameError unless addin.respond_to? method
          end
        end
      end
      
    end
  end
end