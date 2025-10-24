# frozen_string_literal: true

require "fileutils"

module BetterSeo
  module Generators
    class RobotsTxtGenerator
      attr_reader :rules, :sitemaps

      def initialize
        @rules = []
        @sitemaps = []
      end

      # Add rule for user agent
      def add_rule(user_agent, allow: nil, disallow: nil)
        rule = { user_agent: user_agent }
        rule[:allow] = Array(allow).compact if allow
        rule[:disallow] = Array(disallow).compact if disallow
        @rules << rule
        self
      end

      # Set crawl delay for user agent
      def set_crawl_delay(user_agent, seconds)
        rule = @rules.find { |r| r[:user_agent] == user_agent }

        if rule
          rule[:crawl_delay] = seconds
        else
          @rules << { user_agent: user_agent, crawl_delay: seconds }
        end

        self
      end

      # Add sitemap URL
      def add_sitemap(url)
        @sitemaps << url
        self
      end

      # Clear all rules and sitemaps
      def clear
        @rules = []
        @sitemaps = []
        self
      end

      # Generate robots.txt content
      def to_text
        return "" if @rules.empty? && @sitemaps.empty?

        lines = []

        # Generate rules for each user agent
        @rules.each_with_index do |rule, index|
          lines << "User-agent: #{rule[:user_agent]}"

          # Allow directives
          if rule[:allow]
            rule[:allow].each do |path|
              lines << "Allow: #{path}"
            end
          end

          # Disallow directives
          if rule[:disallow]
            rule[:disallow].each do |path|
              lines << "Disallow: #{path}"
            end
          end

          # Crawl delay
          if rule[:crawl_delay]
            lines << "Crawl-delay: #{rule[:crawl_delay]}"
          end

          # Add blank line between user agent sections (except last)
          lines << "" if index < @rules.size - 1
        end

        # Add blank line before sitemaps if there are rules
        lines << "" if @rules.any? && @sitemaps.any?

        # Add sitemaps
        @sitemaps.each do |sitemap|
          lines << "Sitemap: #{sitemap}"
        end

        lines.join("\n")
      end

      # Write robots.txt to file
      def write_to_file(path)
        directory = File.dirname(path)
        FileUtils.mkdir_p(directory) unless File.directory?(directory)
        File.write(path, to_text)
      end
    end
  end
end
