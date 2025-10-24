# frozen_string_literal: true

module BetterSeo
  module StructuredData
    class BreadcrumbList < Base
      attr_reader :items

      def initialize(**properties)
        super("BreadcrumbList", **properties)
        @items = []
      end

      def add_item(name:, url:, position: nil)
        position ||= @items.size + 1
        @items << { name: name, url: url, position: position }
        self
      end

      def add_items(items_array)
        items_array.each do |item|
          add_item(
            name: item[:name],
            url: item[:url],
            position: item[:position]
          )
        end
        self
      end

      def clear
        @items = []
        self
      end

      def to_h
        hash = super
        hash["itemListElement"] = @items.map do |item|
          {
            "@type" => "ListItem",
            "position" => item[:position],
            "name" => item[:name],
            "item" => item[:url]
          }
        end
        hash
      end
    end
  end
end
