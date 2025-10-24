# frozen_string_literal: true

require "json"

module BetterSeo
  module Analytics
    class GoogleAnalytics
      attr_reader :measurement_id, :anonymize_ip

      def initialize(measurement_id, anonymize_ip: false)
        @measurement_id = measurement_id
        @anonymize_ip = anonymize_ip
      end

      # Generate GA4 script tag
      def to_script_tag(nonce: nil, **config)
        nonce_attr = nonce ? %( nonce="#{escape_html(nonce)}") : ""

        config_options = { "anonymize_ip" => @anonymize_ip } if @anonymize_ip
        config_options ||= {}
        config_options.merge!(config.transform_keys(&:to_s))

        config_json = config_options.empty? ? "" : ", #{JSON.generate(config_options)}"

        <<~HTML.strip
          <script async src="https://www.googletagmanager.com/gtag/js?id=#{@measurement_id}"#{nonce_attr}></script>
          <script#{nonce_attr}>
            window.dataLayer = window.dataLayer || [];
            function gtag(){dataLayer.push(arguments);}
            gtag('js', new Date());
            gtag('config', '#{@measurement_id}'#{config_json});
          </script>
        HTML
      end

      # Track custom event
      def track_event(event_name, **parameters)
        params_json = parameters.empty? ? "" : ", #{JSON.generate(parameters.transform_keys(&:to_s))}"

        <<~JS.strip
          gtag('event', '#{event_name}'#{params_json});
        JS
      end

      # Track page view
      def track_page_view(page_path, title: nil)
        params = { "page_path" => page_path }
        params["page_title"] = title if title

        <<~JS.strip
          gtag('config', '#{@measurement_id}', #{JSON.generate(params)});
        JS
      end

      # Track e-commerce purchase
      def ecommerce_purchase(transaction_id:, value:, currency: "USD", items: [])
        params = {
          "transaction_id" => transaction_id,
          "value" => value,
          "currency" => currency,
          "items" => items.map { |item| item.transform_keys(&:to_s) }
        }

        <<~JS.strip
          gtag('event', 'purchase', #{JSON.generate(params)});
        JS
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
