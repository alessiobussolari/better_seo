# frozen_string_literal: true

module BetterSeo
  module DSL
    class MetaTags < Base
      def title(value = nil)
        value ? set(:title, value) : get(:title)
      end

      def description(value = nil)
        value ? set(:description, value) : get(:description)
      end

      def keywords(*values)
        values.any? ? set(:keywords, values.flatten) : get(:keywords)
      end

      def author(value = nil)
        value ? set(:author, value) : get(:author)
      end

      def canonical(value = nil)
        value ? set(:canonical, value) : get(:canonical)
      end

      def robots(index: true, follow: true, **options)
        set(:robots, { index: index, follow: follow }.merge(options))
      end

      def viewport(value = "width=device-width, initial-scale=1.0")
        set(:viewport, value)
      end

      def charset(value = "UTF-8")
        set(:charset, value)
      end

      protected

      def validate!
        errors = []

        if config[:title] && config[:title].length > 60
          errors << "Title too long (#{config[:title].length} chars, max 60 recommended)"
        end

        if config[:description] && config[:description].length > 160
          errors << "Description too long (#{config[:description].length} chars, max 160 recommended)"
        end

        raise ValidationError, errors.join(", ") if errors.any?
      end
    end
  end
end
