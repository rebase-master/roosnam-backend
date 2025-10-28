# config/initializers/sprockets_compat.rb
# Compatibility shim for old gems calling deprecated Sprockets APIs.

if defined?(Sprockets::Environment)
  Sprockets::Environment.class_eval do
    unless method_defined?(:load_path)
      # Return self instead of paths array, so old code can still call methods on it.
      def load_path
        self
      end
    end
  end
end
