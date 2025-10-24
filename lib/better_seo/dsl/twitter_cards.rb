# frozen_string_literal: true

module BetterSeo
  module DSL
    class TwitterCards < Base
      VALID_CARD_TYPES = %w[summary summary_large_image app player].freeze

      def card(value = nil)
        value ? set(:card, value) : get(:card)
      end

      def site(value = nil)
        return get(:site) if value.nil?

        # Ensure @ prefix
        value = "@#{value}" unless value.to_s.start_with?("@")
        set(:site, value)
      end

      def creator(value = nil)
        return get(:creator) if value.nil?

        # Ensure @ prefix
        value = "@#{value}" unless value.to_s.start_with?("@")
        set(:creator, value)
      end

      def title(value = nil)
        value ? set(:title, value) : get(:title)
      end

      def description(value = nil)
        value ? set(:description, value) : get(:description)
      end

      def image(value = nil)
        return get(:image) if value.nil?

        if value.is_a?(Hash)
          set(:image, value)
        else
          set(:image, value)
        end
      end

      def image_alt(value = nil)
        value ? set(:image_alt, value) : get(:image_alt)
      end

      # Player card properties
      def player(value = nil)
        value ? set(:player, value) : get(:player)
      end

      def player_width(value = nil)
        value ? set(:player_width, value) : get(:player_width)
      end

      def player_height(value = nil)
        value ? set(:player_height, value) : get(:player_height)
      end

      def player_stream(value = nil)
        value ? set(:player_stream, value) : get(:player_stream)
      end

      # App card properties
      def app_name(value = nil, platform: nil)
        return get(:app_name) if value.nil?

        if platform
          current = get(:app_name) || {}
          set(:app_name, current.merge(platform => value))
        else
          # Set for all platforms
          set(:app_name, {
            iphone: value,
            ipad: value,
            googleplay: value
          })
        end
      end

      def app_id(value = nil, platform: nil)
        return get(:app_id) if value.nil?

        current = get(:app_id) || {}
        set(:app_id, current.merge(platform => value))
      end

      def app_url(value = nil, platform: nil)
        return get(:app_url) if value.nil?

        current = get(:app_url) || {}
        set(:app_url, current.merge(platform => value))
      end

      protected

      def validate!
        errors = []

        # Validate card type
        card_type = config[:card]
        if card_type && !VALID_CARD_TYPES.include?(card_type)
          errors << "Invalid card type: #{card_type}. Valid types: #{VALID_CARD_TYPES.join(", ")}"
        end

        # Validate required fields
        errors << "twitter:title is required" unless config[:title]
        errors << "twitter:description is required" unless config[:description]

        # Validate image for summary_large_image
        if card_type == "summary_large_image" && !config[:image]
          errors << "twitter:image is required for summary_large_image card"
        end

        # Validate lengths
        if config[:title] && config[:title].length > 70
          errors << "Title too long (#{config[:title].length} chars, max 70 recommended)"
        end

        if config[:description] && config[:description].length > 200
          errors << "Description too long (#{config[:description].length} chars, max 200 recommended)"
        end

        raise ValidationError, errors.join(", ") if errors.any?
      end
    end
  end
end
