# frozen_string_literal: true

module BetterSeo
  module Sitemap
    class Builder
      include Enumerable

      attr_reader :urls

      def initialize(urls: [])
        @urls = urls
      end

      def add_url(location, lastmod: nil, changefreq: "weekly", priority: 0.5)
        @urls << UrlEntry.new(location, lastmod: lastmod, changefreq: changefreq, priority: priority)
        self
      end

      def add_urls(locations, lastmod: nil, changefreq: "weekly", priority: 0.5)
        locations.each do |location|
          add_url(location, lastmod: lastmod, changefreq: changefreq, priority: priority)
        end
        self
      end

      def remove_url(location)
        @urls.reject! { |url| url.loc == location }
        self
      end

      def clear
        @urls = []
        self
      end

      def to_xml
        xml = []
        xml << '<?xml version="1.0" encoding="UTF-8"?>'
        xml << '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
        @urls.each do |url|
          xml << url.to_xml
        end
        xml << "</urlset>"
        xml.join("\n")
      end

      def validate!
        @urls.each(&:validate!)
        true
      end

      def size
        @urls.size
      end

      def empty?
        @urls.empty?
      end

      def each(&block)
        @urls.each(&block)
      end
    end
  end
end
