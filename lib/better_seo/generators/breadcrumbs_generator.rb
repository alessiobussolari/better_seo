# frozen_string_literal: true

require "json"

module BetterSeo
  module Generators
    class BreadcrumbsGenerator
      attr_reader :items

      def initialize
        @items = []
      end

      # Add single breadcrumb item
      def add_item(name, url)
        @items << { name: name, url: url }
        self
      end

      # Add multiple items from array
      def add_items(items_array)
        items_array.each do |item|
          add_item(item[:name], item[:url])
        end
        self
      end

      # Clear all items
      def clear
        @items = []
        self
      end

      # Generate HTML breadcrumbs
      def to_html(schema: false, nav_class: "breadcrumb", list_class: "breadcrumb")
        return "" if @items.empty?

        html = []

        if schema
          html << %(<nav class="#{escape_html(nav_class)}" aria-label="breadcrumb" itemscope itemtype="https://schema.org/BreadcrumbList">)
        else
          html << %(<nav class="#{escape_html(nav_class)}" aria-label="breadcrumb">)
        end

        html << %(  <ol class="#{escape_html(list_class)}">)

        @items.each_with_index do |item, index|
          if schema
            html << %(    <li class="breadcrumb-item#{item[:url].nil? ? " active" : ""}" itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem"#{item[:url].nil? ? ' aria-current="page"' : ""}>)
          else
            html << %(    <li class="breadcrumb-item#{item[:url].nil? ? " active" : ""}"#{item[:url].nil? ? ' aria-current="page"' : ""}>)
          end

          if item[:url]
            if schema
              html << %(      <a href="#{escape_html(item[:url])}" itemprop="item">)
              html << %(        <span itemprop="name">#{escape_html(item[:name])}</span>)
              html << %(      </a>)
              html << %(      <meta itemprop="position" content="#{index + 1}" />)
            else
              html << %(      <a href="#{escape_html(item[:url])}">#{escape_html(item[:name])}</a>)
            end
          else
            if schema
              html << %(      <span itemprop="name">#{escape_html(item[:name])}</span>)
              html << %(      <meta itemprop="position" content="#{index + 1}" />)
            else
              html << %(      #{escape_html(item[:name])})
            end
          end

          html << %(    </li>)
        end

        html << %(  </ol>)
        html << %(</nav>)

        html.join("\n")
      end

      # Generate JSON-LD structured data
      def to_json_ld
        return "" if @items.empty?

        data = {
          "@context" => "https://schema.org",
          "@type" => "BreadcrumbList",
          "itemListElement" => []
        }

        @items.each_with_index do |item, index|
          list_item = {
            "@type" => "ListItem",
            "position" => index + 1,
            "name" => item[:name]
          }
          list_item["item"] = item[:url] if item[:url]
          data["itemListElement"] << list_item
        end

        JSON.generate(data)
      end

      # Generate script tag with JSON-LD
      def to_script_tag
        return "" if @items.empty?

        %(<script type="application/ld+json">\n#{to_json_ld}\n</script>)
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
