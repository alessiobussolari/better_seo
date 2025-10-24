# frozen_string_literal: true

require "uri"
require "date"

module BetterSeo
  module Sitemap
    class UrlEntry
      VALID_CHANGEFREQ = %w[always hourly daily weekly monthly yearly never].freeze

      attr_reader :loc, :lastmod, :changefreq, :priority, :alternates, :images, :videos

      def initialize(loc, lastmod: nil, changefreq: "weekly", priority: 0.5)
        @loc = loc
        @lastmod = format_date(lastmod) if lastmod
        @changefreq = changefreq
        @priority = priority
        @alternates = []
        @images = []
        @videos = []
      end

      def lastmod=(value)
        @lastmod = format_date(value)
      end

      def changefreq=(value)
        unless VALID_CHANGEFREQ.include?(value)
          raise ValidationError, "Invalid changefreq: #{value}. Must be one of: #{VALID_CHANGEFREQ.join(", ")}"
        end

        @changefreq = value
      end

      def priority=(value)
        raise ValidationError, "Priority must be between 0.0 and 1.0" unless value.between?(0.0, 1.0)

        @priority = value
      end

      # Add alternate language version (hreflang)
      def add_alternate(href, hreflang:)
        @alternates << { href: href, hreflang: hreflang }
        self
      end

      # Add image
      def add_image(loc, title: nil, caption: nil)
        image = { loc: loc }
        image[:title] = title if title
        image[:caption] = caption if caption
        @images << image
        self
      end

      # Add video
      def add_video(thumbnail_loc:, title:, description:, content_loc:, duration: nil)
        video = {
          thumbnail_loc: thumbnail_loc,
          title: title,
          description: description,
          content_loc: content_loc
        }
        video[:duration] = duration if duration
        @videos << video
        self
      end

      def to_xml
        xml = []
        xml << "  <url>"
        xml << "    <loc>#{escape_xml(@loc)}</loc>"
        xml << "    <lastmod>#{@lastmod}</lastmod>" if @lastmod
        xml << "    <changefreq>#{@changefreq}</changefreq>"
        xml << "    <priority>#{@priority}</priority>"

        # Add images
        @images.each do |image|
          xml << "    <image:image>"
          xml << "      <image:loc>#{escape_xml(image[:loc])}</image:loc>"
          xml << "      <image:title>#{escape_xml(image[:title])}</image:title>" if image[:title]
          xml << "      <image:caption>#{escape_xml(image[:caption])}</image:caption>" if image[:caption]
          xml << "    </image:image>"
        end

        # Add videos
        @videos.each do |video|
          xml << "    <video:video>"
          xml << "      <video:thumbnail_loc>#{escape_xml(video[:thumbnail_loc])}</video:thumbnail_loc>"
          xml << "      <video:title>#{escape_xml(video[:title])}</video:title>"
          xml << "      <video:description>#{escape_xml(video[:description])}</video:description>"
          xml << "      <video:content_loc>#{escape_xml(video[:content_loc])}</video:content_loc>"
          xml << "      <video:duration>#{video[:duration]}</video:duration>" if video[:duration]
          xml << "    </video:video>"
        end

        # Add hreflang alternates
        @alternates.each do |alternate|
          xml << "    <xhtml:link rel=\"alternate\" hreflang=\"#{alternate[:hreflang]}\" href=\"#{escape_xml(alternate[:href])}\" />"
        end

        xml << "  </url>"
        xml.join("\n")
      end

      def to_h
        hash = {
          loc: @loc,
          changefreq: @changefreq,
          priority: @priority
        }
        hash[:lastmod] = @lastmod if @lastmod
        hash[:alternates] = @alternates if @alternates.any?
        hash
      end

      def validate!
        raise ValidationError, "Location is required" if @loc.nil? || @loc.empty?

        begin
          uri = URI.parse(@loc)
          raise ValidationError, "Invalid URL format: #{@loc}" unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
        rescue URI::InvalidURIError
          raise ValidationError, "Invalid URL format: #{@loc}"
        end

        true
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
