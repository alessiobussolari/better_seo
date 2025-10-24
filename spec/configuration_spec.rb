# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::Configuration do
  subject(:config) { described_class.new }

  describe "#initialize" do
    it "sets default values" do
      expect(config.default_locale).to eq(:en)
      expect(config.available_locales).to eq([:en])
    end

    it "initializes nested configurations" do
      expect(config.meta_tags).to be_a(BetterSeo::Configuration::NestedConfiguration)
      expect(config.open_graph).to be_a(BetterSeo::Configuration::NestedConfiguration)
      expect(config.twitter).to be_a(BetterSeo::Configuration::NestedConfiguration)
      expect(config.structured_data).to be_a(BetterSeo::Configuration::NestedConfiguration)
      expect(config.sitemap).to be_a(BetterSeo::Configuration::NestedConfiguration)
      expect(config.robots).to be_a(BetterSeo::Configuration::NestedConfiguration)
      expect(config.images).to be_a(BetterSeo::Configuration::NestedConfiguration)
      expect(config.i18n).to be_a(BetterSeo::Configuration::NestedConfiguration)
    end

    it "sets meta_tags defaults" do
      expect(config.meta_tags.default_title).to be_nil
      expect(config.meta_tags.title_separator).to eq(" | ")
      expect(config.meta_tags.append_site_name).to be true
    end

    it "sets open_graph defaults" do
      expect(config.open_graph.enabled).to be true
      expect(config.open_graph.default_type).to eq("website")
    end

    it "sets sitemap defaults" do
      expect(config.sitemap.enabled).to be false
      expect(config.sitemap.output_path).to eq("public/sitemap.xml")
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
        },
        sitemap: {
          enabled: true,
          host: "https://example.com"
        }
      }
    end

    it "merges custom configuration" do
      config.load_from_hash(custom_config)

      expect(config.site_name).to eq("My Site")
      expect(config.default_locale).to eq(:it)
      expect(config.available_locales).to eq([:it, :en])
      expect(config.meta_tags.default_title).to eq("Custom Title")
      expect(config.meta_tags.default_description).to eq("Custom Description")
    end

    it "preserves unspecified defaults" do
      config.load_from_hash({ site_name: "Test" })

      expect(config.default_locale).to eq(:en)  # Still default
      expect(config.meta_tags.title_separator).to eq(" | ")  # Still default
    end

    it "handles nested hash merging" do
      config.load_from_hash(custom_config)

      expect(config.sitemap.enabled).to be true
      expect(config.sitemap.host).to eq("https://example.com")
      expect(config.sitemap.output_path).to eq("public/sitemap.xml")  # Default preserved
    end
  end

  describe "#validate!" do
    context "with valid configuration" do
      before do
        config.load_from_hash({
          available_locales: [:it, :en],
          default_locale: :it,
          sitemap: {
            enabled: true,
            host: "https://example.com"
          }
        })
      end

      it "returns true" do
        expect(config.validate!).to be true
      end

      it "does not raise error" do
        expect { config.validate! }.not_to raise_error
      end
    end

    context "with invalid configuration" do
      it "raises error when default_locale not in available_locales" do
        config.default_locale = :fr
        config.available_locales = [:it, :en]

        expect {
          config.validate!
        }.to raise_error(BetterSeo::ValidationError, /default_locale/)
      end

      it "raises error when sitemap enabled without host" do
        config.sitemap.enabled = true
        config.sitemap.host = nil

        expect {
          config.validate!
        }.to raise_error(BetterSeo::ValidationError, /sitemap\.host/)
      end

      it "raises error when title too long" do
        config.meta_tags.default_title = "A" * 80

        expect {
          config.validate!
        }.to raise_error(BetterSeo::ValidationError, /60 characters/)
      end

      it "raises error when description too long" do
        config.meta_tags.default_description = "A" * 200

        expect {
          config.validate!
        }.to raise_error(BetterSeo::ValidationError, /160 characters/)
      end

      it "raises error when available_locales is not an array" do
        config.available_locales = "invalid"

        expect {
          config.validate!
        }.to raise_error(BetterSeo::ValidationError, /must be a non-empty array/)
      end

      it "raises error when available_locales is empty" do
        config.available_locales = []

        expect {
          config.validate!
        }.to raise_error(BetterSeo::ValidationError, /must be a non-empty array/)
      end
    end
  end

  describe "feature enabled checks" do
    it "#sitemap_enabled? returns false by default" do
      expect(config.sitemap_enabled?).to be false
    end

    it "#sitemap_enabled? returns true when enabled" do
      config.sitemap.enabled = true
      expect(config.sitemap_enabled?).to be true
    end

    it "#robots_enabled? returns false by default" do
      expect(config.robots_enabled?).to be false
    end

    it "#open_graph_enabled? returns true by default" do
      expect(config.open_graph_enabled?).to be true
    end

    it "#images_enabled? returns false by default" do
      expect(config.images_enabled?).to be false
    end

    it "#structured_data_enabled? returns true by default" do
      expect(config.structured_data_enabled?).to be true
    end

    it "#twitter_enabled? returns true by default" do
      expect(config.twitter_enabled?).to be true
    end
  end

  describe "#to_h" do
    it "converts configuration to hash" do
      hash = config.to_h

      expect(hash).to be_a(Hash)
      expect(hash[:default_locale]).to eq(:en)
      expect(hash[:meta_tags]).to be_a(Hash)
      expect(hash[:open_graph]).to be_a(Hash)
    end

    it "includes all nested configurations" do
      hash = config.to_h

      expect(hash.keys).to include(
        :site_name,
        :default_locale,
        :available_locales,
        :meta_tags,
        :open_graph,
        :twitter,
        :structured_data,
        :sitemap,
        :robots,
        :images,
        :i18n
      )
    end
  end

  describe "NestedConfiguration" do
    subject(:nested) { config.meta_tags }

    it "allows setting values with method calls" do
      nested.default_title = "Test Title"
      expect(nested.default_title).to eq("Test Title")
    end

    it "allows accessing values with []" do
      nested.default_title = "Test"
      expect(nested[:default_title]).to eq("Test")
    end

    it "allows setting values with []=" do
      nested[:custom_field] = "Custom Value"
      expect(nested.custom_field).to eq("Custom Value")
    end

    it "converts to hash" do
      hash = nested.to_h
      expect(hash).to be_a(Hash)
    end

    it "supports deep merge" do
      nested.merge!(default_title: "New Title", custom: "value")

      expect(nested.default_title).to eq("New Title")
      expect(nested.custom).to eq("value")
      expect(nested.title_separator).to eq(" | ")  # Preserved
    end

    it "raises NoMethodError for non-existent keys without setter" do
      expect {
        nested.non_existent_key
      }.to raise_error(NoMethodError)
    end

    it "dynamically defines accessors when setting new keys with []=" do
      nested[:dynamic_key] = "dynamic_value"

      # Should now respond to the dynamically created method
      expect(nested.respond_to?(:dynamic_key)).to be true
      expect(nested.dynamic_key).to eq("dynamic_value")
    end

    it "dynamically defines accessors when setting new keys with method=" do
      nested.another_dynamic = "another_value"

      # Should now respond to the dynamically created method
      expect(nested.respond_to?(:another_dynamic)).to be true
      expect(nested.another_dynamic).to eq("another_value")
    end

    it "defines singleton methods for new keys" do
      # Create a fresh NestedConfiguration without predefined keys
      fresh_nested = BetterSeo::Configuration::NestedConfiguration.new({})

      # Set a completely new key
      fresh_nested[:brand_new_key] = "brand_new_value"

      # Verify the method was defined on singleton class
      expect(fresh_nested.methods(false)).to include(:brand_new_key)
      expect(fresh_nested.brand_new_key).to eq("brand_new_value")
    end

    it "respond_to? returns false for non-existent keys" do
      fresh_nested = BetterSeo::Configuration::NestedConfiguration.new({})

      # Test respond_to? for a completely non-existent key
      expect(fresh_nested.respond_to?(:totally_non_existent_key)).to be false
    end

    it "uses method_missing for getter when accessor is not yet defined" do
      # Create instance and manually add data without calling define_accessor
      fresh_nested = BetterSeo::Configuration::NestedConfiguration.new({})
      fresh_nested.instance_variable_get(:@data)[:manual_key] = "manual_value"

      # This should go through method_missing
      expect(fresh_nested.manual_key).to eq("manual_value")
    end
  end
end
