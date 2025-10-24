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
          tags = []

          if config[:meta]
            tags << seo_meta_tags(config[:meta])
          end

          if config[:og]
            tags << seo_open_graph_tags(config[:og])
          end

          if config[:twitter]
            tags << seo_twitter_tags(config[:twitter])
          end

          raw(tags.compact.join("\n"))
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
