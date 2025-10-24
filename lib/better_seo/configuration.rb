# frozen_string_literal: true

require "active_support/core_ext/hash/indifferent_access"
require "active_support/core_ext/hash/deep_merge"

module BetterSeo
  class Configuration
    # Default values
    DEFAULT_CONFIG = {
      site_name: nil,
      default_locale: :en,
      available_locales: [:en],

      # Meta tags defaults
      meta_tags: {
        default_title: nil,
        title_separator: " | ",
        append_site_name: true,
        default_description: nil,
        default_keywords: [],
        default_author: nil
      },

      # Open Graph defaults
      open_graph: {
        enabled: true,
        site_name: nil,
        default_type: "website",
        default_locale: "en_US",
        default_image: {
          url: nil,
          width: 1200,
          height: 630
        }
      },

      # Twitter Cards defaults
      twitter: {
        enabled: true,
        site: nil,
        creator: nil,
        card_type: "summary_large_image"
      },

      # Structured Data defaults
      structured_data: {
        enabled: true,
        organization: {},
        website: {}
      },

      # Sitemap defaults
      sitemap: {
        enabled: false,
        output_path: "public/sitemap.xml",
        host: nil,
        compress: false,
        ping_search_engines: false,
        defaults: {
          changefreq: "weekly",
          priority: 0.5
        }
      },

      # Robots.txt defaults
      robots: {
        enabled: false,
        output_path: "public/robots.txt",
        user_agents: {
          "*" => {
            allow: ["/"],
            disallow: [],
            crawl_delay: nil
          }
        }
      },

      # Image optimization defaults
      images: {
        enabled: false,
        webp: {
          enabled: true,
          quality: 80
        },
        sizes: {
          thumbnail: { width: 150, height: 150 },
          small: { width: 300 },
          medium: { width: 600 },
          large: { width: 1200 },
          og_image: { width: 1200, height: 630, crop: true }
        }
      },

      # I18n settings
      i18n: {
        load_path: "config/locales/seo/**/*.yml",
        auto_reload: false
      }
    }.freeze

    attr_accessor :site_name, :default_locale, :available_locales
    attr_reader :meta_tags, :open_graph, :twitter, :structured_data,
                :sitemap, :robots, :images, :i18n

    def initialize
      # Deep dup per evitare shared state
      @config = deep_dup(DEFAULT_CONFIG)

      # Initialize nested configurations
      @meta_tags = NestedConfiguration.new(@config[:meta_tags])
      @open_graph = NestedConfiguration.new(@config[:open_graph])
      @twitter = NestedConfiguration.new(@config[:twitter])
      @structured_data = NestedConfiguration.new(@config[:structured_data])
      @sitemap = NestedConfiguration.new(@config[:sitemap])
      @robots = NestedConfiguration.new(@config[:robots])
      @images = NestedConfiguration.new(@config[:images])
      @i18n = NestedConfiguration.new(@config[:i18n])

      # Top-level attributes
      @site_name = @config[:site_name]
      @default_locale = @config[:default_locale]
      @available_locales = @config[:available_locales]
    end

    # Load configuration from hash
    def load_from_hash(hash)
      merge_hash!(hash)
      self
    end

    # Validate configuration
    def validate!
      errors = []

      # Validate locales
      unless available_locales.is_a?(Array) && available_locales.any?
        errors << "available_locales must be a non-empty array"
      end

      if available_locales.is_a?(Array) && !available_locales.include?(default_locale)
        errors << "default_locale must be included in available_locales"
      end

      # Validate sitemap
      if sitemap.enabled && sitemap.host.nil?
        errors << "sitemap.host is required when sitemap is enabled"
      end

      # Validate meta tags lengths
      if meta_tags.default_title && meta_tags.default_title.length > 60
        errors << "meta_tags.default_title should be max 60 characters"
      end

      if meta_tags.default_description && meta_tags.default_description.length > 160
        errors << "meta_tags.default_description should be max 160 characters"
      end

      raise ValidationError, errors.join(", ") if errors.any?

      true
    end

    # Feature enabled checks
    def sitemap_enabled?
      sitemap.enabled == true
    end

    def robots_enabled?
      robots.enabled == true
    end

    def images_enabled?
      images.enabled == true
    end

    def open_graph_enabled?
      open_graph.enabled == true
    end

    def twitter_enabled?
      twitter.enabled == true
    end

    def structured_data_enabled?
      structured_data.enabled == true
    end

    # Convert to hash
    def to_h
      {
        site_name: site_name,
        default_locale: default_locale,
        available_locales: available_locales,
        meta_tags: meta_tags.to_h,
        open_graph: open_graph.to_h,
        twitter: twitter.to_h,
        structured_data: structured_data.to_h,
        sitemap: sitemap.to_h,
        robots: robots.to_h,
        images: images.to_h,
        i18n: i18n.to_h
      }
    end

    private

    def merge_hash!(hash)
      hash = hash.with_indifferent_access if hash.respond_to?(:with_indifferent_access)

      # Merge top-level attributes
      @site_name = hash[:site_name] if hash.key?(:site_name)
      @default_locale = hash[:default_locale] if hash.key?(:default_locale)
      @available_locales = hash[:available_locales] if hash.key?(:available_locales)

      # Merge nested configurations
      @meta_tags.merge!(hash[:meta_tags]) if hash[:meta_tags]
      @open_graph.merge!(hash[:open_graph]) if hash[:open_graph]
      @twitter.merge!(hash[:twitter]) if hash[:twitter]
      @structured_data.merge!(hash[:structured_data]) if hash[:structured_data]
      @sitemap.merge!(hash[:sitemap]) if hash[:sitemap]
      @robots.merge!(hash[:robots]) if hash[:robots]
      @images.merge!(hash[:images]) if hash[:images]
      @i18n.merge!(hash[:i18n]) if hash[:i18n]
    end

    def deep_dup(hash)
      hash.transform_values do |value|
        value.is_a?(Hash) ? deep_dup(value) : (value.dup rescue value)
      end
    end

    # Nested configuration object
    class NestedConfiguration
      def initialize(hash = {})
        @data = hash.with_indifferent_access
        define_accessors!
      end

      def merge!(other_hash)
        @data.deep_merge!(other_hash.with_indifferent_access)
        define_accessors!
        self
      end

      def to_h
        @data.deep_dup
      end

      def [](key)
        @data[key]
      end

      def []=(key, value)
        @data[key] = value
        define_accessor(key)
      end

      def method_missing(method_name, *args, &block)
        method_str = method_name.to_s

        if method_str.end_with?("=")
          key = method_str.chomp("=").to_sym
          @data[key] = args.first
          define_accessor(key)
        elsif @data.key?(method_name)
          @data[method_name]
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        @data.key?(method_name.to_s.chomp("=").to_sym) || super
      end

      private

      def define_accessors!
        @data.keys.each { |key| define_accessor(key) }
      end

      def define_accessor(key)
        # Check if method is actually defined (not just available via method_missing)
        return if singleton_class.method_defined?(key)

        singleton_class.class_eval do
          define_method(key) { @data[key] }
          define_method("#{key}=") { |value| @data[key] = value }
        end
      end
    end
  end
end
