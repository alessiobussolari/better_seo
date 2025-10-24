# frozen_string_literal: true

module BetterSeo
  module DSL
    class Base
      attr_reader :config

      def initialize
        @config = {}
      end

      # Generic setter method
      def set(key, value)
        @config[key] = value
        self
      end

      # Generic getter method
      def get(key)
        @config[key]
      end

      # Block evaluation
      def evaluate(&block)
        instance_eval(&block) if block_given?
        self
      end

      # Build final configuration
      def build
        validate!
        @config.dup
      end

      # Convert to hash
      def to_h
        @config.dup
      end

      # Merge another config
      def merge!(other)
        if other.is_a?(Hash)
          @config.merge!(other)
        elsif other.respond_to?(:to_h)
          @config.merge!(other.to_h)
        else
          raise DSLError, "Cannot merge #{other.class}"
        end
        self
      end

      protected

      # Override in subclasses for validation
      def validate!
        true
      end

      # Dynamic method handling
      def method_missing(method_name, *args, &block)
        method_str = method_name.to_s

        if method_str.end_with?("=")
          # Setter: title = "value"
          key = method_str.chomp("=").to_sym
          set(key, args.first)
        elsif block_given?
          # Nested block: open_graph do ... end
          nested_builder = self.class.new
          nested_builder.evaluate(&block)
          set(method_name, nested_builder.build)
        elsif args.any?
          # Setter without =: title "value"
          set(method_name, args.first)
        else
          # Getter
          get(method_name)
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        true
      end
    end
  end
end
