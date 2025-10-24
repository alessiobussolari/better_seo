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
        available_locales: %i[it en],
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
      expect(config.available_locales).to eq(%i[it en])
      expect(config.meta_tags.default_title).to eq("Custom Title")
      expect(config.meta_tags.default_description).to eq("Custom Description")
    end

    it "preserves unspecified defaults" do
      config.load_from_hash({ site_name: "Test" })

      expect(config.default_locale).to eq(:en) # Still default
      expect(config.meta_tags.title_separator).to eq(" | ") # Still default
    end

    it "handles nested hash merging" do
      config.load_from_hash(custom_config)

      expect(config.sitemap.enabled).to be true
      expect(config.sitemap.host).to eq("https://example.com")
      expect(config.sitemap.output_path).to eq("public/sitemap.xml") # Default preserved
    end
  end

  describe "#validate!" do
    context "with valid configuration" do
      before do
        config.load_from_hash({
                                available_locales: %i[it en],
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
        config.available_locales = %i[it en]

        expect do
          config.validate!
        end.to raise_error(BetterSeo::ValidationError, /default_locale/)
      end

      it "raises error when sitemap enabled without host" do
        config.sitemap.enabled = true
        config.sitemap.host = nil

        expect do
          config.validate!
        end.to raise_error(BetterSeo::ValidationError, /sitemap\.host/)
      end

      it "raises error when title too long" do
        config.meta_tags.default_title = "A" * 80

        expect do
          config.validate!
        end.to raise_error(BetterSeo::ValidationError, /60 characters/)
      end

      it "raises error when description too long" do
        config.meta_tags.default_description = "A" * 200

        expect do
          config.validate!
        end.to raise_error(BetterSeo::ValidationError, /160 characters/)
      end

      it "raises error when available_locales is not an array" do
        config.available_locales = "invalid"

        expect do
          config.validate!
        end.to raise_error(BetterSeo::ValidationError, /must be a non-empty array/)
      end

      it "raises error when available_locales is empty" do
        config.available_locales = []

        expect do
          config.validate!
        end.to raise_error(BetterSeo::ValidationError, /must be a non-empty array/)
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
      expect(nested.title_separator).to eq(" | ") # Preserved
    end

    it "raises NoMethodError for non-existent keys without setter" do
      expect do
        nested.non_existent_key
      end.to raise_error(NoMethodError)
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

  describe "nested hash wrapping" do
    context "during initialization" do
      it "wraps nested hashes in NestedConfiguration objects" do
        # open_graph.default_image is a nested hash in the config
        default_image = config.open_graph.default_image

        expect(default_image).to be_a(BetterSeo::Configuration::NestedConfiguration)
        expect(default_image).not_to be_a(Hash)
      end

      it "allows setter access on deeply nested hashes" do
        # This is the key test for the bug we fixed
        expect do
          config.open_graph.default_image.url = "https://example.com/image.jpg"
        end.not_to raise_error

        expect(config.open_graph.default_image.url).to eq("https://example.com/image.jpg")
      end

      it "supports multi-level nesting with getters and setters" do
        # Set values at multiple levels
        config.open_graph.default_image.url = "https://test.com/og.jpg"
        config.open_graph.default_image.width = 1200
        config.open_graph.default_image.height = 630

        # Verify all values were set correctly
        expect(config.open_graph.default_image.url).to eq("https://test.com/og.jpg")
        expect(config.open_graph.default_image.width).to eq(1200)
        expect(config.open_graph.default_image.height).to eq(630)
      end

      it "wraps sitemap.defaults hash" do
        # sitemap.defaults is another nested hash
        expect(config.sitemap.defaults).to be_a(BetterSeo::Configuration::NestedConfiguration)

        # Should be able to set values
        config.sitemap.defaults.changefreq = "daily"
        expect(config.sitemap.defaults.changefreq).to eq("daily")
      end

      it "wraps images.webp hash" do
        expect(config.images.webp).to be_a(BetterSeo::Configuration::NestedConfiguration)

        config.images.webp.enabled = false
        expect(config.images.webp.enabled).to be false
      end

      it "wraps images.sizes.og_image hash (triple nesting)" do
        expect(config.images.sizes).to be_a(BetterSeo::Configuration::NestedConfiguration)
        expect(config.images.sizes.og_image).to be_a(BetterSeo::Configuration::NestedConfiguration)

        config.images.sizes.og_image.width = 1600
        expect(config.images.sizes.og_image.width).to eq(1600)
      end
    end

    context "when assigning hash values" do
      it "wraps hash assigned with []=" do
        nested = BetterSeo::Configuration::NestedConfiguration.new({})

        nested[:new_nested] = { key1: "value1", key2: "value2" }

        expect(nested.new_nested).to be_a(BetterSeo::Configuration::NestedConfiguration)
        expect(nested.new_nested.key1).to eq("value1")
        expect(nested.new_nested.key2).to eq("value2")
      end

      it "wraps hash assigned with method setter" do
        nested = BetterSeo::Configuration::NestedConfiguration.new({})

        nested.custom_config = { option1: "opt1", option2: "opt2" }

        expect(nested.custom_config).to be_a(BetterSeo::Configuration::NestedConfiguration)
        expect(nested.custom_config.option1).to eq("opt1")
        expect(nested.custom_config.option2).to eq("opt2")
      end

      it "does not wrap non-hash values" do
        nested = BetterSeo::Configuration::NestedConfiguration.new({})

        nested.string_value = "just a string"
        nested.number_value = 42
        nested.array_value = [1, 2, 3]

        expect(nested.string_value).to eq("just a string")
        expect(nested.number_value).to eq(42)
        expect(nested.array_value).to eq([1, 2, 3])
      end
    end

    context "with merge!" do
      it "wraps nested hashes after merge" do
        nested = BetterSeo::Configuration::NestedConfiguration.new({ existing: "value" })

        nested.merge!({
                        new_nested: {
                          inner_key: "inner_value"
                        }
                      })

        expect(nested.new_nested).to be_a(BetterSeo::Configuration::NestedConfiguration)
        expect(nested.new_nested.inner_key).to eq("inner_value")
      end

      it "preserves existing NestedConfiguration objects" do
        nested = BetterSeo::Configuration::NestedConfiguration.new({
                                                                     existing_nested: { key: "original" }
                                                                   })

        original_object_id = nested.existing_nested.object_id

        nested.merge!({ other_key: "value" })

        # Should still be a NestedConfiguration with same object_id
        expect(nested.existing_nested).to be_a(BetterSeo::Configuration::NestedConfiguration)
        expect(nested.existing_nested.object_id).to eq(original_object_id)
      end
    end

    context "real-world scenario: generator template" do
      it "allows setting default_image properties individually (generator template syntax)" do
        # This is exactly what the generator template does
        expect do
          config.open_graph.default_image.url = "https://example.com/default-og-image.jpg"
          config.open_graph.default_image.width = 1200
          config.open_graph.default_image.height = 630
          config.open_graph.default_image.alt = "Default image description"
        end.not_to raise_error

        expect(config.open_graph.default_image.url).to eq("https://example.com/default-og-image.jpg")
        expect(config.open_graph.default_image.width).to eq(1200)
        expect(config.open_graph.default_image.height).to eq(630)
        expect(config.open_graph.default_image.alt).to eq("Default image description")
      end

      it "works with BetterSeo.configure block (real usage)" do
        BetterSeo.reset_configuration!

        expect do
          BetterSeo.configure do |c|
            c.site_name = "Test Site"
            c.open_graph.site_name = "Test Site OG"
            c.open_graph.default_image.url = "https://test.com/og.jpg"
            c.open_graph.default_image.width = 1200
            c.open_graph.default_image.height = 630
          end
        end.not_to raise_error

        config = BetterSeo.configuration
        expect(config.site_name).to eq("Test Site")
        expect(config.open_graph.site_name).to eq("Test Site OG")
        expect(config.open_graph.default_image.url).to eq("https://test.com/og.jpg")
        expect(config.open_graph.default_image.width).to eq(1200)

        # Reset for other tests
        BetterSeo.reset_configuration!
      end

      it "converts nested hash back to plain hash with to_h" do
        config.open_graph.default_image.url = "https://test.com/image.jpg"
        config.open_graph.default_image.width = 1000

        hash = config.to_h

        expect(hash[:open_graph]).to be_a(Hash)
        expect(hash[:open_graph][:default_image]).to be_a(Hash)
        expect(hash[:open_graph][:default_image][:url]).to eq("https://test.com/image.jpg")
        expect(hash[:open_graph][:default_image][:width]).to eq(1000)
      end
    end

    context "edge cases" do
      it "handles empty hash assignment" do
        nested = BetterSeo::Configuration::NestedConfiguration.new({})
        nested.empty_hash = {}

        expect(nested.empty_hash).to be_a(BetterSeo::Configuration::NestedConfiguration)
      end

      it "handles nil assignment (does not wrap)" do
        nested = BetterSeo::Configuration::NestedConfiguration.new({})
        nested.nil_value = nil

        expect(nested.nil_value).to be_nil
      end

      it "prevents wrapping already wrapped NestedConfiguration" do
        nested1 = BetterSeo::Configuration::NestedConfiguration.new({ key: "value" })
        nested2 = BetterSeo::Configuration::NestedConfiguration.new({})

        nested2.existing = nested1

        # Should not double-wrap
        expect(nested2.existing).to be(nested1)
        expect(nested2.existing.key).to eq("value")
      end
    end
  end
end
