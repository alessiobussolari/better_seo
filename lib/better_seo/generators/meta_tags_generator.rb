# frozen_string_literal: true

module BetterSeo
  module Generators
    class MetaTagsGenerator
      def initialize(config)
        @config = config
      end

      def generate
        tags = []
        tags << charset_tag
        tags << viewport_tag
        tags << title_tag
        tags << description_tag
        tags << keywords_tag
        tags << author_tag
        tags << robots_tag
        tags << canonical_tag

        tags.compact.join("\n")
      end

      def charset_tag
        return nil unless @config[:charset]

        %(<meta charset="#{escape(@config[:charset])}">)
      end

      def viewport_tag
        return nil unless @config[:viewport]

        %(<meta name="viewport" content="#{escape(@config[:viewport])}">)
      end

      def title_tag
        return nil unless @config[:title]

        %(<title>#{escape(@config[:title])}</title>)
      end

      def description_tag
        return nil unless @config[:description]

        %(<meta name="description" content="#{escape(@config[:description])}">)
      end

      def keywords_tag
        keywords = @config[:keywords]
        return nil unless keywords&.any?

        keywords_str = Array(keywords).join(", ")
        %(<meta name="keywords" content="#{escape(keywords_str)}">)
      end

      def author_tag
        return nil unless @config[:author]

        %(<meta name="author" content="#{escape(@config[:author])}">)
      end

      def canonical_tag
        return nil unless @config[:canonical]

        %(<link rel="canonical" href="#{escape(@config[:canonical])}">)
      end

      def robots_tag
        robots = @config[:robots]
        return nil unless robots

        directives = []

        # Index/noindex
        directives << (robots[:index] ? "index" : "noindex")

        # Follow/nofollow
        directives << (robots[:follow] ? "follow" : "nofollow")

        # Additional directives
        robots.each do |key, value|
          next if %i[index follow].include?(key)

          directives << key.to_s if value
        end

        %(<meta name="robots" content="#{directives.join(", ")}">)
      end

      private

      def escape(text)
        text.to_s
            .gsub("&", "&amp;")
            .gsub('"', "&quot;")
            .gsub("<", "&lt;")
            .gsub(">", "&gt;")
      end
    end
  end
end
