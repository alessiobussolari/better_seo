# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo do
  it "has a version number" do
    expect(BetterSeo::VERSION).not_to be_nil
    expect(BetterSeo::VERSION).to match(/^\d+\.\d+\.\d+(\.\d+)?$/)
  end

  describe ".configuration" do
    it "returns a Configuration instance" do
      expect(described_class.configuration).to be_a(BetterSeo::Configuration)
    end

    it "returns the same instance on multiple calls (singleton)" do
      config1 = described_class.configuration
      config2 = described_class.configuration

      expect(config1).to equal(config2)
    end
  end

  describe ".configure" do
    it "yields configuration to block" do
      expect { |b| described_class.configure(&b) }.to yield_with_args(BetterSeo::Configuration)
    end

    it "allows setting configuration values" do
      described_class.configure do |config|
        config.site_name = "Test Site"
        config.default_locale = :it
        config.available_locales = %i[it en]
      end

      expect(described_class.configuration.site_name).to eq("Test Site")
      expect(described_class.configuration.default_locale).to eq(:it)
    end

    it "validates configuration after block" do
      expect do
        described_class.configure do |config|
          config.default_locale = :fr
          config.available_locales = %i[it en] # fr not included
        end
      end.to raise_error(BetterSeo::ValidationError)
    end

    it "returns configuration" do
      result = described_class.configure do |config|
        config.site_name = "Test"
      end

      expect(result).to be_a(BetterSeo::Configuration)
    end

    it "does not validate if no block given" do
      expect do
        described_class.configure
      end.not_to raise_error
    end
  end

  describe ".reset_configuration!" do
    it "resets configuration to defaults" do
      described_class.configure do |config|
        config.site_name = "Custom Site"
      end

      described_class.reset_configuration!

      expect(described_class.configuration.site_name).to be_nil
    end

    it "returns new Configuration instance" do
      old_config = described_class.configuration

      described_class.reset_configuration!

      new_config = described_class.configuration
      expect(new_config).not_to equal(old_config)
    end
  end

  describe ".enabled?" do
    it "returns true when feature is enabled" do
      described_class.configuration.open_graph.enabled = true
      expect(described_class.enabled?(:open_graph)).to be true
    end

    it "returns false when feature is disabled" do
      described_class.configuration.sitemap.enabled = false
      expect(described_class.enabled?(:sitemap)).to be false
    end

    it "returns false for non-existent features" do
      expect(described_class.enabled?(:non_existent)).to be false
    end

    it "handles various feature names" do
      expect(described_class.enabled?(:robots)).to be false  # disabled by default
      expect(described_class.enabled?(:images)).to be false  # disabled by default
      expect(described_class.enabled?(:twitter)).to be true # enabled by default
    end
  end
end
