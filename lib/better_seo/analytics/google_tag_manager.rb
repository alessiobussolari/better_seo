# frozen_string_literal: true

require "json"

module BetterSeo
  module Analytics
    class GoogleTagManager
      attr_reader :container_id, :data_layer_name

      def initialize(container_id, data_layer_name: "dataLayer")
        @container_id = container_id
        @data_layer_name = data_layer_name
      end

      # Generate GTM head script tag
      def to_head_script(nonce: nil)
        nonce_attr = nonce ? %( nonce="#{escape_html(nonce)}") : ""

        <<~HTML.strip
          <script#{nonce_attr}>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
          new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
          j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
          'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
          })(window,document,'script','#{@data_layer_name}','#{@container_id}');</script>
        HTML
      end

      # Generate GTM body noscript tag
      def to_body_noscript
        <<~HTML.strip
          <noscript><iframe src="https://www.googletagmanager.com/ns.html?id=#{@container_id}"
          height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
        HTML
      end

      # Push data to data layer
      def push_data_layer(**data)
        <<~JS.strip
          #{@data_layer_name}.push(#{JSON.generate(data.transform_keys(&:to_s))});
        JS
      end

      # Push e-commerce data
      def push_ecommerce(event:, ecommerce:)
        data = {
          "event" => event,
          "ecommerce" => ecommerce.transform_keys(&:to_s)
        }

        <<~JS.strip
          #{@data_layer_name}.push(#{JSON.generate(data)});
        JS
      end

      # Push user data
      def push_user_data(**user_data)
        push_data_layer(**user_data)
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
