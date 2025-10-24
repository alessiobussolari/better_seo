# frozen_string_literal: true

require "uri"

module BetterSeo
  module Generators
    class CanonicalUrlManager
      attr_reader :url
      attr_accessor :remove_query_params, :lowercase

      def initialize(url = nil)
        @remove_query_params = false
        @lowercase = false
        self.url = url if url
      end

      def url=(value)
        return @url = nil if value.nil?

        @url = normalize_url(value)
      end

      # Generate canonical link HTML tag
      def to_html
        return "" unless @url

        %(<link rel="canonical" href="#{escape_html(@url)}">)
      end

      # Generate Link HTTP header
      def to_http_header
        return "" unless @url

        %(<#{@url}>; rel="canonical")
      end

      # Validate the canonical URL
      def validate!
        raise ValidationError, "URL is required" if @url.nil? || @url.empty?

        begin
          uri = URI.parse(@url)

          # Check if it's a relative URL
          unless uri.absolute?
            raise ValidationError, "Canonical URL must be absolute: #{@url}"
          end

          # Check if it's HTTP or HTTPS
          unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
            raise ValidationError, "Invalid URL format: #{@url}"
          end
        rescue URI::InvalidURIError
          raise ValidationError, "Invalid URL format: #{@url}"
        end

        true
      end

      private

      def normalize_url(url)
        return url if url.empty?

        normalized = url.dup

        # Parse URL
        begin
          uri = URI.parse(normalized)
        rescue URI::InvalidURIError
          return normalized
        end

        # Remove fragment identifier
        uri.fragment = nil

        # Remove query parameters if configured
        uri.query = nil if @remove_query_params

        # Rebuild URL
        normalized = uri.to_s

        # Remove trailing slash (except for root URL)
        if normalized.end_with?("/") && normalized.count("/") > 3
          normalized = normalized[0...-1]
        end

        # Lowercase if configured
        normalized = normalized.downcase if @lowercase

        normalized
      end

      def escape_html(text)
        return "" if text.nil?

        text.to_s
          .gsub("&", "&amp;")
          .gsub("<", "&lt;")
          .gsub(">", "&gt;")
          .gsub('"', "&quot;")
          .gsub("'", "&#39;")
      end
    end
  end
end
