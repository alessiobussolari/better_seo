# frozen_string_literal: true

module BetterSeo
  module Generators
    class OpenGraphGenerator
      def initialize(config)
        @config = config
      end

      def generate
        tags = []
        tags << meta_tag("og:title", @config[:title])
        tags << meta_tag("og:description", @config[:description])
        tags << meta_tag("og:type", @config[:type])
        tags << meta_tag("og:url", @config[:url])
        tags.concat(image_tags)
        tags << meta_tag("og:site_name", @config[:site_name])
        tags << meta_tag("og:locale", @config[:locale])
        tags.concat(locale_alternate_tags)
        tags.concat(article_tags)
        tags.concat(video_tags)
        tags << meta_tag("og:audio", @config[:audio])

        tags.compact.join("\n")
      end

      private

      def meta_tag(property, content)
        return nil unless content

        %(<meta property="#{property}" content="#{escape(content)}">)
      end

      def image_tags
        image = @config[:image]
        return [] unless image

        tags = []

        if image.is_a?(Hash)
          tags << meta_tag("og:image", image[:url])
          tags << meta_tag("og:image:width", image[:width])
          tags << meta_tag("og:image:height", image[:height])
          tags << meta_tag("og:image:alt", image[:alt])
        else
          tags << meta_tag("og:image", image)
        end

        tags.compact
      end

      def locale_alternate_tags
        alternates = @config[:locale_alternate]
        return [] unless alternates && alternates.any?

        Array(alternates).map do |locale|
          meta_tag("og:locale:alternate", locale)
        end
      end

      def article_tags
        article = @config[:article]
        return [] unless article

        tags = []
        tags << meta_tag("article:author", article[:author])
        tags << meta_tag("article:published_time", article[:published_time])
        tags << meta_tag("article:modified_time", article[:modified_time])
        tags << meta_tag("article:expiration_time", article[:expiration_time])
        tags << meta_tag("article:section", article[:section])

        # Handle multiple tags
        if article[:tag]
          Array(article[:tag]).each do |tag|
            tags << meta_tag("article:tag", tag)
          end
        end

        tags.compact
      end

      def video_tags
        video = @config[:video]
        return [] unless video

        tags = []

        if video.is_a?(Hash)
          tags << meta_tag("og:video", video[:url])
          tags << meta_tag("og:video:width", video[:width])
          tags << meta_tag("og:video:height", video[:height])
          tags << meta_tag("og:video:type", video[:type])
        else
          tags << meta_tag("og:video", video)
        end

        tags.compact
      end

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
