# frozen_string_literal: true

module BetterSeo
  module StructuredData
    class Article < Base
      def initialize(**properties)
        super("Article", **properties)
      end

      def headline(value)
        set(:headline, value)
      end

      def description(value)
        set(:description, value)
      end

      def image(value)
        set(:image, value)
      end

      def author(value)
        set(:author, value)
      end

      def publisher(value)
        set(:publisher, value)
      end

      def date_published(value)
        set(:datePublished, value)
      end

      def date_modified(value)
        set(:dateModified, value)
      end

      def url(value)
        set(:url, value)
      end

      def word_count(value)
        set(:wordCount, value)
      end

      def keywords(value)
        set(:keywords, value)
      end

      def article_section(value)
        set(:articleSection, value)
      end
    end
  end
end
