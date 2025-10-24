# frozen_string_literal: true

require "json"

module BetterSeo
  module StructuredData
    class Base
      attr_reader :type, :properties

      def initialize(type, **properties)
        @type = type
        @properties = {}
        properties.each { |key, value| set(key, value) }
      end

      def set(key, value)
        @properties[key] = value unless value.nil?
        self
      end

      def get(key)
        @properties[key]
      end

      def to_h
        hash = {
          "@context" => "https://schema.org",
          "@type" => @type
        }

        @properties.each do |key, value|
          hash[key.to_s] = convert_value(value)
        end

        hash
      end

      def to_json(*_args)
        JSON.pretty_generate(to_h)
      end

      def to_script_tag
        <<~HTML.strip
          <script type="application/ld+json">
          #{to_json}
          </script>
        HTML
      end

      def valid?
        !@type.nil? && !@type.to_s.empty?
      end

      def validate!
        raise ValidationError, "@type is required for structured data" unless valid?

        true
      end

      private

      def convert_value(value)
        case value
        when Base
          value.to_h
        when Array
          value.map { |v| convert_value(v) }
        else
          value
        end
      end
    end
  end
end
