# frozen_string_literal: true

module BetterSeo
  module Rails
    module Helpers
      module ControllerHelpers
        extend ActiveSupport::Concern

        included do
          helper_method :better_seo_data if respond_to?(:helper_method)
        end

        # Set meta tags data
        def set_meta_tags(data = nil, &block)
          if block_given?
            meta_data = {}
            yield(meta_data)
            merge_seo_data(:meta, meta_data)
          else
            merge_seo_data(:meta, data)
          end
        end

        # Set Open Graph tags data
        def set_og_tags(data = nil, &block)
          if block_given?
            og_data = {}
            yield(og_data)
            merge_seo_data(:og, og_data)
          else
            merge_seo_data(:og, data)
          end
        end

        # Set Twitter Card tags data
        def set_twitter_tags(data = nil, &block)
          if block_given?
            twitter_data = {}
            yield(twitter_data)
            merge_seo_data(:twitter, twitter_data)
          else
            merge_seo_data(:twitter, data)
          end
        end

        # Set canonical URL
        def set_canonical(url)
          merge_seo_data(:meta, { canonical: url })
        end

        # Set page title with optional prefix/suffix
        def set_page_title(title, prefix: nil, suffix: nil)
          full_title = ""
          full_title += prefix if prefix
          full_title += title
          full_title += suffix if suffix

          merge_seo_data(:meta, { title: full_title })
        end

        # Set page description with optional truncation
        def set_page_description(description, max_length: nil)
          final_description = description

          if max_length && description.length > max_length
            final_description = description[0...max_length - 3] + "..."
          end

          merge_seo_data(:meta, { description: final_description })
        end

        # Set page keywords (array or comma-separated string)
        def set_page_keywords(keywords)
          keywords_array = if keywords.is_a?(String)
                             keywords.split(",").map(&:strip)
                           else
                             keywords
                           end

          merge_seo_data(:meta, { keywords: keywords_array })
        end

        # Set page image for both OG and Twitter
        def set_page_image(url, width: nil, height: nil)
          og_data = { image: url }
          og_data[:image_width] = width if width
          og_data[:image_height] = height if height

          merge_seo_data(:og, og_data)
          merge_seo_data(:twitter, { image: url })
        end

        # Set noindex robot directive
        def set_noindex(nofollow: false)
          robots = "noindex"
          robots += ", nofollow" if nofollow

          merge_seo_data(:meta, { robots: robots })
        end

        # Get all SEO data stored in controller
        def better_seo_data
          @_better_seo_data ||= {}
        end

        private

        def merge_seo_data(category, data)
          return unless data

          @_better_seo_data ||= {}
          @_better_seo_data[category] ||= {}
          @_better_seo_data[category].merge!(data)
        end
      end
    end
  end
end
