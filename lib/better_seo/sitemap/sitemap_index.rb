# frozen_string_literal: true

require "fileutils"
require "date"

module BetterSeo
  module Sitemap
    class SitemapIndex
      attr_reader :sitemaps

      def initialize
        @sitemaps = []
      end

      # Add a sitemap to the index
      def add_sitemap(loc, lastmod: nil)
        sitemap = { loc: loc }
        sitemap[:lastmod] = format_date(lastmod) if lastmod
        @sitemaps << sitemap
        self
      end

      # Generate XML for sitemap index
      def to_xml
        xml = []
        xml << '<?xml version="1.0" encoding="UTF-8"?>'
        xml << '<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'

        @sitemaps.each do |sitemap|
          xml << "  <sitemap>"
          xml << "    <loc>#{escape_xml(sitemap[:loc])}</loc>"
          xml << "    <lastmod>#{sitemap[:lastmod]}</lastmod>" if sitemap[:lastmod]
          xml << "  </sitemap>"
        end

        xml << "</sitemapindex>"
        xml.join("\n")
      end

      # Write sitemap index to file
      def write_to_file(path)
        directory = File.dirname(path)
        FileUtils.mkdir_p(directory) unless File.directory?(directory)

        File.write(path, to_xml)
      end

      private

      def format_date(value)
        case value
        when String
          value
        when Date
          value.strftime("%Y-%m-%d")
        when Time, DateTime
          value.strftime("%Y-%m-%d")
        else
          value.to_s
        end
      end

      def escape_xml(text)
        text.to_s
          .gsub("&", "&amp;")
          .gsub("<", "&lt;")
          .gsub(">", "&gt;")
          .gsub('"', "&quot;")
          .gsub("'", "&apos;")
      end
    end
  end
end
