# frozen_string_literal: true

module BetterSeo
  module DSL
    class OpenGraph < Base
      def title(value = nil)
        value ? set(:title, value) : get(:title)
      end

      def description(value = nil)
        value ? set(:description, value) : get(:description)
      end

      def type(value = nil)
        value ? set(:type, value) : get(:type)
      end

      def url(value = nil)
        value ? set(:url, value) : get(:url)
      end

      def image(value = nil)
        return get(:image) if value.nil?

        if value.is_a?(Hash)
          set(:image, value)
        else
          set(:image, value)
        end
      end

      def site_name(value = nil)
        value ? set(:site_name, value) : get(:site_name)
      end

      def locale(value = nil)
        value ? set(:locale, value) : get(:locale)
      end

      def locale_alternate(*values)
        values.any? ? set(:locale_alternate, values.flatten) : get(:locale_alternate)
      end

      def article(&block)
        if block_given?
          article_builder = ArticleBuilder.new
          article_builder.evaluate(&block)
          set(:article, article_builder.build)
        else
          get(:article)
        end
      end

      def video(value = nil)
        return get(:video) if value.nil?

        if value.is_a?(Hash)
          set(:video, value)
        else
          set(:video, value)
        end
      end

      def audio(value = nil)
        value ? set(:audio, value) : get(:audio)
      end

      protected

      def validate!
        errors = []

        errors << "og:title is required" unless config[:title]
        errors << "og:type is required" unless config[:type]
        errors << "og:image is required" unless config[:image]
        errors << "og:url is required" unless config[:url]

        raise ValidationError, errors.join(", ") if errors.any?
      end

      # Article builder for og:article properties
      class ArticleBuilder < Base
        def author(value = nil)
          value ? set(:author, value) : get(:author)
        end

        def published_time(value = nil)
          value ? set(:published_time, value) : get(:published_time)
        end

        def modified_time(value = nil)
          value ? set(:modified_time, value) : get(:modified_time)
        end

        def expiration_time(value = nil)
          value ? set(:expiration_time, value) : get(:expiration_time)
        end

        def section(value = nil)
          value ? set(:section, value) : get(:section)
        end

        def tag(*values)
          values.any? ? set(:tag, values.flatten) : get(:tag)
        end
      end
    end
  end
end
