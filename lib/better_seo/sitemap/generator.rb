# frozen_string_literal: true

require "fileutils"

module BetterSeo
  module Sitemap
    class Generator
      class << self
        def generate
          builder = Builder.new
          yield(builder) if block_given?
          builder.to_xml
        end

        def generate_from(urls, lastmod: nil, changefreq: "weekly", priority: 0.5)
          builder = Builder.new
          builder.add_urls(urls, lastmod: lastmod, changefreq: changefreq, priority: priority)
          builder.to_xml
        end

        def generate_from_collection(collection, url: nil, lastmod: nil, changefreq: "weekly", priority: 0.5)
          raise ArgumentError, "url option is required" if url.nil?
          raise ArgumentError, "url option must be callable" unless url.respond_to?(:call)

          builder = Builder.new

          collection.each do |item|
            url_value = url.call(item)
            lastmod_value = lastmod.respond_to?(:call) ? lastmod.call(item) : lastmod
            changefreq_value = changefreq.respond_to?(:call) ? changefreq.call(item) : changefreq
            priority_value = priority.respond_to?(:call) ? priority.call(item) : priority

            builder.add_url(
              url_value,
              lastmod: lastmod_value,
              changefreq: changefreq_value,
              priority: priority_value
            )
          end

          builder.to_xml
        end

        def write_to_file(file_path, &block)
          xml = generate(&block)

          # Create parent directories if they don't exist
          dir = File.dirname(file_path)
          FileUtils.mkdir_p(dir) unless File.directory?(dir)

          File.write(file_path, xml)
          file_path
        end
      end
    end
  end
end
