# frozen_string_literal: true

require "json"

module BetterSeo
  module Generators
    class AmpGenerator
      attr_accessor :canonical_url, :title, :description, :image, :structured_data

      def initialize(canonical_url: nil, title: nil, description: nil, image: nil, structured_data: nil)
        @canonical_url = canonical_url
        @title = title
        @description = description
        @image = image
        @structured_data = structured_data
      end

      # Generate AMP boilerplate CSS
      def to_boilerplate
        boilerplate = <<~HTML
          <style amp-boilerplate>body{-webkit-animation:-amp-start 8s steps(1,end) 0s 1 normal both;-moz-animation:-amp-start 8s steps(1,end) 0s 1 normal both;-ms-animation:-amp-start 8s steps(1,end) 0s 1 normal both;animation:-amp-start 8s steps(1,end) 0s 1 normal both}@-webkit-keyframes -amp-start{from{visibility:hidden}to{visibility:visible}}@-moz-keyframes -amp-start{from{visibility:hidden}to{visibility:visible}}@-ms-keyframes -amp-start{from{visibility:hidden}to{visibility:visible}}@-o-keyframes -amp-start{from{visibility:hidden}to{visibility:visible}}@keyframes -amp-start{from{visibility:hidden}to{visibility:visible}}</style><noscript><style amp-boilerplate>body{-webkit-animation:none;-moz-animation:none;-ms-animation:none;animation:none}</style></noscript>
        HTML
        boilerplate.strip
      end

      # Generate AMP runtime script tag
      def to_amp_script_tag
        '<script async src="https://cdn.ampproject.org/v0.js"></script>'
      end

      # Generate meta tags for AMP page
      def to_meta_tags
        tags = []

        if @canonical_url
          tags << %(<link rel="canonical" href="#{escape_html(@canonical_url)}">)
        end

        if @title
          tags << %(<meta property="og:title" content="#{escape_html(@title)}">)
        end

        if @description
          tags << %(<meta name="description" content="#{escape_html(@description)}">)
          tags << %(<meta property="og:description" content="#{escape_html(@description)}">)
        end

        if @image
          tags << %(<meta property="og:image" content="#{escape_html(@image)}">)
        end

        tags.join("\n")
      end

      # Generate structured data script tag
      def to_structured_data
        return "" unless @structured_data

        %(<script type="application/ld+json">\n#{JSON.generate(@structured_data)}\n</script>)
      end

      # Wrap custom CSS in amp-custom style tag
      def to_custom_css(css)
        return "" if css.nil? || css.empty?

        %(<style amp-custom>\n#{css}\n</style>)
      end

      private

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
