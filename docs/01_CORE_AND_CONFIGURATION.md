# Step 01: Core e Sistema di Configurazione

**Versione Target**: 0.2.0
**Durata Stimata**: 1-2 settimane
**Priorità**: 🔴 CRITICA (Foundation)

---

## Obiettivi dello Step

Creare il sistema fondamentale di BetterSeo:

1. ✅ Sistema di configurazione YAML/JSON
2. ✅ DSL base pattern per builder
3. ✅ Custom errors e validazione
4. ✅ Rails Railtie per integrazione automatica
5. ✅ Configuration loader con environment support
6. ✅ Test suite completa per core

---

## File da Creare/Modificare

### File Principali

```
lib/better_seo.rb                          # Entry point principale
lib/better_seo/version.rb                  # Già esistente
lib/better_seo/configuration.rb            # Sistema configurazione
lib/better_seo/errors.rb                   # Custom errors
lib/better_seo/dsl/base.rb                 # DSL base pattern
lib/better_seo/rails/railtie.rb            # Rails integration
```

### File di Test

```
spec/configuration_spec.rb
spec/dsl/base_spec.rb
spec/errors_spec.rb
spec/rails/railtie_spec.rb
```

### File di Supporto

```
lib/better_seo/support/hash_with_indifferent_access.rb  # Helper per config
lib/better_seo/support/deep_merge.rb                    # Deep merge YAML
```

---

## Dipendenze Gem

Aggiungere al `better_seo.gemspec`:

```ruby
spec.add_dependency "activesupport", ">= 6.1"  # Per HashWithIndifferentAccess, Concerns
spec.add_dependency "yaml", "~> 0.2"           # YAML parsing (built-in Ruby)

# Development dependencies
spec.add_development_dependency "rails", ">= 6.1"
spec.add_development_dependency "rspec-rails", "~> 6.0"
spec.add_development_dependency "simplecov", "~> 0.22"  # Code coverage
```

---

## Implementazione Dettagliata

### 1. Entry Point (`lib/better_seo.rb`)

```ruby
# frozen_string_literal: true

require "active_support"
require "active_support/core_ext"
require "yaml"

require_relative "better_seo/version"
require_relative "better_seo/errors"
require_relative "better_seo/configuration"
require_relative "better_seo/dsl/base"

# Rails integration (caricato solo se Rails è presente)
require_relative "better_seo/rails/railtie" if defined?(Rails::Railtie)

module BetterSeo
  class Error < StandardError; end

  class << self
    # Accesso alla configurazione singleton
    def configuration
      @configuration ||= Configuration.new
    end

    # Block-style configuration
    def configure
      yield(configuration) if block_given?
      configuration.validate!
      configuration
    end

    # Reset configuration (utile per test)
    def reset_configuration!
      @configuration = Configuration.new
    end

    # Shortcut per check feature enabled
    def enabled?(feature)
      configuration.public_send("#{feature}_enabled?")
    rescue NoMethodError
      false
    end
  end
end
```

---

### 2. Configuration System (`lib/better_seo/configuration.rb`)

```ruby
# frozen_string_literal: true

require "active_support/core_ext/hash/indifferent_access"

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

    # Load configuration from YAML file
    def load_from_file(path, environment: nil)
      unless File.exist?(path)
        raise ConfigurationError, "Configuration file not found: #{path}"
      end

      yaml_content = YAML.load_file(path)

      # Se c'è environment, carica quella sezione
      config_hash = if environment && yaml_content[environment.to_s]
        yaml_content[environment.to_s]
      else
        yaml_content
      end

      merge_hash!(config_hash)
      self
    end

    # Load from hash
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

      unless available_locales.include?(default_locale)
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
        value.is_a?(Hash) ? deep_dup(value) : value.dup rescue value
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
        return if respond_to?(key, true)

        singleton_class.class_eval do
          define_method(key) { @data[key] }
          define_method("#{key}=") { |value| @data[key] = value }
        end
      end
    end
  end
end
```

---

### 3. Custom Errors (`lib/better_seo/errors.rb`)

```ruby
# frozen_string_literal: true

module BetterSeo
  # Base error class
  class Error < StandardError; end

  # Configuration errors
  class ConfigurationError < Error; end
  class ValidationError < Error; end

  # DSL errors
  class DSLError < Error; end
  class InvalidBuilderError < DSLError; end

  # Generator errors
  class GeneratorError < Error; end
  class TemplateNotFoundError < GeneratorError; end

  # Validator errors
  class ValidatorError < Error; end
  class InvalidDataError < ValidatorError; end

  # Image errors
  class ImageError < Error; end
  class ImageConversionError < ImageError; end
  class ImageValidationError < ImageError; end

  # I18n errors
  class I18nError < Error; end
  class MissingTranslationError < I18nError; end
end
```

---

### 4. DSL Base Pattern (`lib/better_seo/dsl/base.rb`)

```ruby
# frozen_string_literal: true

module BetterSeo
  module DSL
    class Base
      attr_reader :config

      def initialize
        @config = {}
      end

      # Generic setter method
      def set(key, value)
        @config[key] = value
        self
      end

      # Generic getter method
      def get(key)
        @config[key]
      end

      # Block evaluation
      def evaluate(&block)
        instance_eval(&block) if block_given?
        self
      end

      # Build final configuration
      def build
        validate!
        @config.dup
      end

      # Convert to hash
      def to_h
        @config.dup
      end

      # Merge another config
      def merge!(other)
        if other.is_a?(Hash)
          @config.merge!(other)
        elsif other.respond_to?(:to_h)
          @config.merge!(other.to_h)
        else
          raise DSLError, "Cannot merge #{other.class}"
        end
        self
      end

      protected

      # Override in subclasses for validation
      def validate!
        true
      end

      # Dynamic method handling
      def method_missing(method_name, *args, &block)
        method_str = method_name.to_s

        if method_str.end_with?("=")
          # Setter: title = "value"
          key = method_str.chomp("=").to_sym
          set(key, args.first)
        elsif block_given?
          # Nested block: open_graph do ... end
          nested_builder = self.class.new
          nested_builder.evaluate(&block)
          set(method_name, nested_builder.build)
        elsif args.any?
          # Setter without =: title "value"
          set(method_name, args.first)
        else
          # Getter
          get(method_name)
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        true
      end
    end
  end
end
```

---

### 5. Rails Railtie (`lib/better_seo/rails/railtie.rb`)

```ruby
# frozen_string_literal: true

require "rails/railtie"

module BetterSeo
  module Rails
    class Railtie < ::Rails::Railtie
      # Auto-load helpers in Rails views
      initializer "better_seo.helpers" do
        ActiveSupport.on_load(:action_view) do
          # Will be implemented in Step 05
          # include BetterSeo::Rails::Helpers::MetaTagsHelper
          # include BetterSeo::Rails::Helpers::OpenGraphHelper
          # include BetterSeo::Rails::Helpers::StructuredDataHelper
        end
      end

      # Auto-load concerns in Rails controllers
      initializer "better_seo.concerns" do
        ActiveSupport.on_load(:action_controller) do
          # Will be implemented in Step 05
          # include BetterSeo::Rails::Concerns::SeoAware
        end
      end

      # Load configuration from Rails config
      initializer "better_seo.configuration" do |app|
        config_file = app.root.join("config", "better_seo.yml")

        if config_file.exist?
          BetterSeo.configure do |config|
            config.load_from_file(config_file, environment: ::Rails.env)
          end
        end

        # Sync with Rails i18n if not configured
        if BetterSeo.configuration.available_locales == [:en]
          BetterSeo.configuration.available_locales = I18n.available_locales
          BetterSeo.configuration.default_locale = I18n.default_locale
        end
      end

      # Add i18n load paths
      initializer "better_seo.i18n" do |app|
        seo_locales_path = app.root.join("config", "locales", "seo", "**", "*.yml")
        I18n.load_path += Dir[seo_locales_path]
      end

      # Rake tasks
      rake_tasks do
        # Will be loaded in future steps
        # load "tasks/better_seo/sitemap.rake"
        # load "tasks/better_seo/robots.rake"
        # load "tasks/better_seo/images.rake"
        # load "tasks/better_seo/i18n.rake"
      end
    end
  end
end
```

---

## Test Suite

### 1. Configuration Test (`spec/configuration_spec.rb`)

```ruby
# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::Configuration do
  subject(:config) { described_class.new }

  describe "#initialize" do
    it "sets default values" do
      expect(config.default_locale).to eq(:en)
      expect(config.available_locales).to eq([:en])
      expect(config.meta_tags.default_title).to be_nil
    end

    it "initializes nested configurations" do
      expect(config.meta_tags).to be_a(BetterSeo::Configuration::NestedConfiguration)
      expect(config.open_graph).to be_a(BetterSeo::Configuration::NestedConfiguration)
    end
  end

  describe "#load_from_hash" do
    let(:custom_config) do
      {
        site_name: "My Site",
        default_locale: :it,
        available_locales: [:it, :en],
        meta_tags: {
          default_title: "Custom Title",
          default_description: "Custom Description"
        }
      }
    end

    it "merges custom configuration" do
      config.load_from_hash(custom_config)

      expect(config.site_name).to eq("My Site")
      expect(config.default_locale).to eq(:it)
      expect(config.meta_tags.default_title).to eq("Custom Title")
    end
  end

  describe "#load_from_file" do
    let(:yaml_path) { "spec/fixtures/config/better_seo.yml" }

    before do
      allow(File).to receive(:exist?).with(yaml_path).and_return(true)
      allow(YAML).to receive(:load_file).with(yaml_path).and_return({
        "production" => {
          "site_name" => "Production Site",
          "sitemap" => { "enabled" => true, "host" => "https://example.com" }
        }
      })
    end

    it "loads configuration from YAML file" do
      config.load_from_file(yaml_path, environment: :production)

      expect(config.site_name).to eq("Production Site")
      expect(config.sitemap.enabled).to be true
    end

    it "raises error if file not found" do
      allow(File).to receive(:exist?).and_return(false)

      expect {
        config.load_from_file("nonexistent.yml")
      }.to raise_error(BetterSeo::ConfigurationError, /not found/)
    end
  end

  describe "#validate!" do
    context "with valid configuration" do
      before do
        config.load_from_hash({
          available_locales: [:it, :en],
          default_locale: :it
        })
      end

      it "returns true" do
        expect(config.validate!).to be true
      end
    end

    context "with invalid configuration" do
      it "raises error when default_locale not in available_locales" do
        config.default_locale = :fr

        expect {
          config.validate!
        }.to raise_error(BetterSeo::ValidationError, /default_locale/)
      end

      it "raises error when sitemap enabled without host" do
        config.sitemap.enabled = true
        config.sitemap.host = nil

        expect {
          config.validate!
        }.to raise_error(BetterSeo::ValidationError, /sitemap.host/)
      end

      it "raises error when title too long" do
        config.meta_tags.default_title = "A" * 80

        expect {
          config.validate!
        }.to raise_error(BetterSeo::ValidationError, /60 characters/)
      end
    end
  end

  describe "feature checks" do
    it "checks if sitemap is enabled" do
      expect(config.sitemap_enabled?).to be false

      config.sitemap.enabled = true
      expect(config.sitemap_enabled?).to be true
    end

    it "checks if images optimization is enabled" do
      expect(config.images_enabled?).to be false

      config.images.enabled = true
      expect(config.images_enabled?).to be true
    end
  end

  describe "#to_h" do
    it "converts configuration to hash" do
      hash = config.to_h

      expect(hash).to be_a(Hash)
      expect(hash[:default_locale]).to eq(:en)
      expect(hash[:meta_tags]).to be_a(Hash)
    end
  end
end
```

### 2. DSL Base Test (`spec/dsl/base_spec.rb`)

```ruby
# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::DSL::Base do
  subject(:builder) { described_class.new }

  describe "#set and #get" do
    it "sets and gets values" do
      builder.set(:title, "My Title")
      expect(builder.get(:title)).to eq("My Title")
    end
  end

  describe "method_missing for setters" do
    it "sets values using method calls" do
      builder.title "My Title"
      expect(builder.get(:title)).to eq("My Title")
    end

    it "sets values using assignment" do
      builder.title = "My Title"
      expect(builder.get(:title)).to eq("My Title")
    end
  end

  describe "nested blocks" do
    it "supports nested configuration blocks" do
      builder.evaluate do
        title "Main Title"

        open_graph do
          title "OG Title"
          image "https://example.com/image.jpg"
        end
      end

      expect(builder.get(:title)).to eq("Main Title")
      expect(builder.get(:open_graph)).to eq({
        title: "OG Title",
        image: "https://example.com/image.jpg"
      })
    end
  end

  describe "#build" do
    it "returns configuration hash" do
      builder.title "Title"
      builder.description "Description"

      result = builder.build

      expect(result).to eq({
        title: "Title",
        description: "Description"
      })
    end
  end

  describe "#merge!" do
    it "merges hash configuration" do
      builder.title "Original"

      builder.merge!(description: "Added", keywords: ["seo", "ruby"])

      expect(builder.get(:title)).to eq("Original")
      expect(builder.get(:description)).to eq("Added")
      expect(builder.get(:keywords)).to eq(["seo", "ruby"])
    end

    it "merges another builder" do
      other = described_class.new
      other.title "Other Title"
      other.description "Other Description"

      builder.merge!(other)

      expect(builder.get(:title)).to eq("Other Title")
      expect(builder.get(:description)).to eq("Other Description")
    end
  end
end
```

---

## Checklist Completamento

### Implementazione
- [ ] `lib/better_seo.rb` implementato con configure block
- [ ] `lib/better_seo/configuration.rb` con nested config support
- [ ] `lib/better_seo/errors.rb` con tutte le custom errors
- [ ] `lib/better_seo/dsl/base.rb` con builder pattern
- [ ] `lib/better_seo/rails/railtie.rb` con auto-configuration
- [ ] Dipendenze gem aggiunte al gemspec

### Testing
- [ ] `spec/configuration_spec.rb` con test coverage > 90%
- [ ] `spec/dsl/base_spec.rb` con test coverage > 90%
- [ ] `spec/errors_spec.rb` con test per ogni error class
- [ ] `spec/rails/railtie_spec.rb` con test integration Rails
- [ ] SimpleCov configurato per code coverage
- [ ] Tutti i test passano (green)

### Documentazione
- [ ] Commenti YARD su metodi pubblici
- [ ] README aggiornato con esempio configurazione base
- [ ] CHANGELOG.md aggiornato per v0.2.0

### Quality Assurance
- [ ] Rubocop pass (0 offenses)
- [ ] No deprecation warnings
- [ ] Memory leaks check
- [ ] Performance benchmark (overhead < 1ms)

---

## Prossimi Passi

Una volta completato questo step:

1. ✅ Sistema di configurazione funzionante
2. ✅ DSL base pronto per estensioni
3. ✅ Rails integration automatica
4. → **Procedere con Step 02**: Meta Tags e Open Graph

---

**Status**: 📝 TODO
**Ultima modifica**: 2025-10-22
