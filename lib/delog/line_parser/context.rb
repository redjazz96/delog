module Delog
  class LineParser

    # Run a block within a defined context, only allowing specific methods to be
    # accessible to the block.  This is to help prevent instance_exec on other
    # classes, providing access to things that shouldn't be accessed.  It allows
    # modules to be included.
    class Context

      # The current class that the context is running in.  This can be nil if
      # the klass was invalidated or there is no running context.
      attr_reader :current_klass

      # Initialize the class.
      def initialize
        @methods_available = {}
        @old_methods = []
      end

      # Add a method to the context.  Accepts a block.  Invalidates the current
      # class, because the available methods have changed.
      def add_method(name, klass)
        @methods_available[name] = klass
        invalidate_klass
      end

      # Removes a method from the context.  This removes it completely.  It
      # invalidates the class, because the available methods have changed.
      def remove_method(name)
        @methods_available.delete(name)
        invalidate_klass
      end

      # This defines the klass for us so we don't have to bother about it later.
      # Or, in #run_with, it'll create the klass for us.  A block is optional.
      def define_klass(&block)
        @current_klass = defined_klass.new
        @current_klass.instance_exec(&block) if block_given?
      end

      # Grabs the defiend class from #defined_klass.  It then instantizes the 
      # class, sets it to current_klass, and executes the block. Then 
      # invalidates the klass using #invalidate_klass.
      def run_with(&block)
        define_klass(&block)
        invalidate_klass
      end

      alias :run :run_with

      # Runs with the currently running class.  Raises a NoContextError if the
      # current class doesn't exist.
      def run_with_current!(*args, &block)
        raise NoContextError, "No defined class!" unless current_klass

        current_klass.instance_exec(*args, &block)
      end

      def run_with_current(*args, &block)
        begin
          run_with_current!(*args, &block)
        rescue NoContextError
        end
      end

      # Grabs the defined class.  If it doesn't exist, it creates it using
      # #create_klass.
      def defined_klass
        @defined_klass ||= create_klass
      end

      # This is called when something with the class changes, such as an added
      # or removed method.  Therefore, when defining methods on the fly inside
      # of the context, you shouldn't rely on that method always being there
      # across contexts.
      #
      #
      def invalidate_klass
        @defined_klass = nil
        @current_klass = nil
      end


      private

      # Create the class used for the context.  It includes all of the arguments
      # passed to it (which means they have to be a Module).  Uses the methods
      # available to define methods that can be used by the class.  Provides a
      # pretty inspect so it's more understandable in errors.
      def create_klass
        klass = Class.new do
          # Pretty inspect.
          def inspect
            "#<Delog::LineParser::Proxy::CurrentClass:0x%014x>" % [self.object_id]
          end

          # Pretty inspect.
          def self.inspect
            "#<Delog::LineParser::Proxy::DefinedClass:0x%014x>" % [self.object_id]
          end
        end

        @old_methods = []
        define_methods(klass)

        klass
      end

      # Define the methods on the class +klass+.  First removes the previously
      # defined methods, then defines the new methods.
      def define_methods(klass)
        @old_methods.each do |m|
          klass.send(:remove_method, m)
        end
        @old_methods = []

        @methods_available.each_pair do |method, receiver|
          unless receiver.respond_to?(method)
            raise NameError,
              "undefined method `#{method}' for #{receiver.inspect}"
          end

          klass.send(:define_method, method) do |*args, &b|
            receiver.__send__(method, *args, &b)
          end
          @old_methods << method
        end

        klass
      end
    end

    class NoContextError < StandardError; end
  end
end