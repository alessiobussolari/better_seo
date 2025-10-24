# frozen_string_literal: true

module BetterSeo
  module Generators
    class TwitterCardsGenerator
      def initialize(config)
        @config = config
      end

      def generate
        tags = []
        tags << meta_tag("twitter:card", @config[:card])
        tags << meta_tag("twitter:site", @config[:site])
        tags << meta_tag("twitter:creator", @config[:creator])
        tags << meta_tag("twitter:title", @config[:title])
        tags << meta_tag("twitter:description", @config[:description])
        tags.concat(image_tags)
        tags.concat(player_tags)
        tags.concat(app_tags)

        tags.compact.join("\n")
      end

      private

      def meta_tag(name, content)
        return nil unless content

        %(<meta name="#{name}" content="#{escape(content)}">)
      end

      def image_tags
        image = @config[:image]
        return [] unless image

        tags = []

        if image.is_a?(Hash)
          tags << meta_tag("twitter:image", image[:url])
          tags << meta_tag("twitter:image:alt", image[:alt])
        else
          tags << meta_tag("twitter:image", image)
        end

        # Add separate image_alt if present
        tags << meta_tag("twitter:image:alt", @config[:image_alt]) if @config[:image_alt]

        tags.compact
      end

      def player_tags
        return [] unless @config[:player]

        tags = []
        tags << meta_tag("twitter:player", @config[:player])
        tags << meta_tag("twitter:player:width", @config[:player_width])
        tags << meta_tag("twitter:player:height", @config[:player_height])
        tags << meta_tag("twitter:player:stream", @config[:player_stream])

        tags.compact
      end

      def app_tags
        tags = []

        # App name tags
        if @config[:app_name]
          app_name = @config[:app_name]
          tags << meta_tag("twitter:app:name:iphone", app_name[:iphone])
          tags << meta_tag("twitter:app:name:ipad", app_name[:ipad])
          tags << meta_tag("twitter:app:name:googleplay", app_name[:googleplay])
        end

        # App ID tags
        if @config[:app_id]
          app_id = @config[:app_id]
          tags << meta_tag("twitter:app:id:iphone", app_id[:iphone])
          tags << meta_tag("twitter:app:id:ipad", app_id[:ipad])
          tags << meta_tag("twitter:app:id:googleplay", app_id[:googleplay])
        end

        # App URL tags
        if @config[:app_url]
          app_url = @config[:app_url]
          tags << meta_tag("twitter:app:url:iphone", app_url[:iphone])
          tags << meta_tag("twitter:app:url:ipad", app_url[:ipad])
          tags << meta_tag("twitter:app:url:googleplay", app_url[:googleplay])
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
