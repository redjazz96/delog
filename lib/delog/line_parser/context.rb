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

      # Grabs the defiend class from #defined_klass, and adds the includes from
      # the arguments (which requires an invalidation of the klass).  It then
      # instantizes the class, sets it to current_klass, and executes the block.
      # Then invalidates the klass using #invalidate_klass.
      def run_with(*includes, &block)
        defined_klass.instance_exec do
          includes.each do |m|
            include m
          end
        end

        @current_klass = defined_klass.new
        @current_klass.instance_exec(&block)
        invalidate_klass
      end

      alias :run :run_with

      # Runs with the currently running class.
      def run_with_current(*args, &block)
        return unless current_klass

        current_klass.instance_exec(*args, &block)
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

        @methods_available.each_pair do |k, v|
          klass.send(:define_method, k) do |*args, &b|
            v.__send__(k, *args, &b)
          end
        end

        klass
      end
    end
  end
end