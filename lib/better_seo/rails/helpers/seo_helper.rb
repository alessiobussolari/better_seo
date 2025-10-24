# frozen_string_literal: true

module BetterSeo
  module Rails
    module Helpers
      module SeoHelper
        # Generate meta tags from configuration or block
        def seo_meta_tags(config = nil, &block)
          if block_given?
            builder = BetterSeo::DSL::MetaTags.new
            builder.evaluate(&block)
            config = builder.build
          end

          generator = BetterSeo::Generators::MetaTagsGenerator.new(config || {})
          raw(generator.generate)
        end

        # Generate Open Graph tags from configuration or block
        def seo_open_graph_tags(config = nil, &block)
          if block_given?
            builder = BetterSeo::DSL::OpenGraph.new
            builder.evaluate(&block)
            config = builder.build
          end

          generator = BetterSeo::Generators::OpenGraphGenerator.new(config || {})
          raw(generator.generate)
        end

        # Generate Twitter Card tags from configuration or block
        def seo_twitter_tags(config = nil, &block)
          if block_given?
            builder = BetterSeo::DSL::TwitterCards.new
            builder.evaluate(&block)
            config = builder.build
          end

          generator = BetterSeo::Generators::TwitterCardsGenerator.new(config || {})
          raw(generator.generate)
        end

        # Generate all SEO tags (meta + og + twitter) from configuration or block
        def seo_tags(config = nil, &block)
          if block_given?
            context = SeoTagsContext.new
            yield(context)
            config = context.to_h
          end

          config ||= {}

          # Merge with defaults from BetterSeo configuration
          merged_config = build_seo_config(config)

          tags = []

          if merged_config[:meta]
            tags << seo_meta_tags(merged_config[:meta])
          end

          if merged_config[:og] && BetterSeo.configuration.open_graph_enabled?
            tags << seo_open_graph_tags(merged_config[:og])
          end

          if merged_config[:twitter] && BetterSeo.configuration.twitter_enabled?
            tags << seo_twitter_tags(merged_config[:twitter])
          end

          raw(tags.compact.join("\n"))
        end

        private

        # Build SEO configuration by merging controller data with defaults
        def build_seo_config(controller_data)
          config = BetterSeo.configuration
          result = {}

          # Meta tags
          meta = {}

          # Start with controller data
          if controller_data[:meta]
            meta = controller_data[:meta].dup
          end

          # Use default title if not set
          meta[:title] ||= config.meta_tags.default_title

          # Apply site_name to title if configured
          if meta[:title] && config.meta_tags.append_site_name && config.site_name
            separator = config.meta_tags.title_separator || " | "
            meta[:title] = "#{meta[:title]}#{separator}#{config.site_name}"
          end

          # Use defaults for missing values
          meta[:description] ||= config.meta_tags.default_description
          meta[:keywords] ||= config.meta_tags.default_keywords
          meta[:author] ||= config.meta_tags.default_author

          result[:meta] = meta if meta.any?

          # Open Graph tags
          if config.open_graph_enabled?
            og = controller_data[:og]&.dup || {}

            # Use meta title/description as fallbacks
            og[:title] ||= meta[:title] || config.meta_tags.default_title
            og[:description] ||= meta[:description]
            og[:type] ||= config.open_graph.default_type
            og[:locale] ||= config.open_graph.default_locale
            og[:site_name] ||= config.open_graph.site_name || config.site_name

            # Default image
            if og[:image].nil? && config.open_graph.default_image&.url
              og[:image] = config.open_graph.default_image.url
              og[:image_width] = config.open_graph.default_image.width
              og[:image_height] = config.open_graph.default_image.height
              og[:image_alt] = config.open_graph.default_image.alt if config.open_graph.default_image.respond_to?(:alt)
            end

            result[:og] = og if og.any?
          end

          # Twitter Card tags
          if config.twitter_enabled?
            twitter = controller_data[:twitter]&.dup || {}

            twitter[:card] ||= config.twitter.card_type
            twitter[:site] ||= config.twitter.site
            twitter[:creator] ||= config.twitter.creator
            twitter[:title] ||= meta[:title] || config.meta_tags.default_title
            twitter[:description] ||= meta[:description]

            # Use OG image as fallback
            twitter[:image] ||= result.dig(:og, :image)

            result[:twitter] = twitter if twitter.any?
          end

          result
        end

        # Context class for building all SEO tags with block syntax
        class SeoTagsContext
          def initialize
            @config = {}
          end

          def meta(&block)
            builder = BetterSeo::DSL::MetaTags.new
            builder.evaluate(&block)
            @config[:meta] = builder.build
          end

          def og(&block)
            builder = BetterSeo::DSL::OpenGraph.new
            builder.evaluate(&block)
            @config[:og] = builder.build
          end

          def twitter(&block)
            builder = BetterSeo::DSL::TwitterCards.new
            builder.evaluate(&block)
            @config[:twitter] = builder.build
          end

          def to_h
            @config
          end
        end
      end
    end
  end
end
