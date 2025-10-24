# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::Sitemap::UrlEntry do
  describe "#initialize" do
    it "creates entry with location" do
      entry = described_class.new("https://example.com/page")
      expect(entry.loc).to eq("https://example.com/page")
    end

    it "sets default values" do
      entry = described_class.new("https://example.com")
      expect(entry.lastmod).to be_nil
      expect(entry.changefreq).to eq("weekly")
      expect(entry.priority).to eq(0.5)
    end

    it "accepts custom values" do
      entry = described_class.new(
        "https://example.com",
        lastmod: "2024-01-01",
        changefreq: "daily",
        priority: 0.8
      )
      expect(entry.lastmod).to eq("2024-01-01")
      expect(entry.changefreq).to eq("daily")
      expect(entry.priority).to eq(0.8)
    end
  end

  describe "#lastmod=" do
    it "accepts string date" do
      entry = described_class.new("https://example.com")
      entry.lastmod = "2024-01-01"
      expect(entry.lastmod).to eq("2024-01-01")
    end

    it "accepts Date object" do
      entry = described_class.new("https://example.com")
      date = Date.new(2024, 1, 1)
      entry.lastmod = date
      expect(entry.lastmod).to eq("2024-01-01")
    end

    it "accepts Time object" do
      entry = described_class.new("https://example.com")
      time = Time.new(2024, 1, 1, 12, 0, 0)
      entry.lastmod = time
      expect(entry.lastmod).to eq("2024-01-01")
    end

    it "accepts DateTime object" do
      entry = described_class.new("https://example.com")
      datetime = DateTime.new(2024, 1, 1, 12, 0, 0)
      entry.lastmod = datetime
      expect(entry.lastmod).to eq("2024-01-01")
    end
  end

  describe "#changefreq=" do
    it "accepts valid changefreq values" do
      valid_values = %w[always hourly daily weekly monthly yearly never]
      entry = described_class.new("https://example.com")

      valid_values.each do |value|
        entry.changefreq = value
        expect(entry.changefreq).to eq(value)
      end
    end

    it "raises error for invalid changefreq" do
      entry = described_class.new("https://example.com")
      expect {
        entry.changefreq = "invalid"
      }.to raise_error(BetterSeo::ValidationError, /Invalid changefreq/)
    end
  end

  describe "#priority=" do
    it "accepts priority between 0.0 and 1.0" do
      entry = described_class.new("https://example.com")
      entry.priority = 0.0
      expect(entry.priority).to eq(0.0)

      entry.priority = 0.5
      expect(entry.priority).to eq(0.5)

      entry.priority = 1.0
      expect(entry.priority).to eq(1.0)
    end

    it "raises error for priority < 0.0" do
      entry = described_class.new("https://example.com")
      expect {
        entry.priority = -0.1
      }.to raise_error(BetterSeo::ValidationError, /Priority must be between 0.0 and 1.0/)
    end

    it "raises error for priority > 1.0" do
      entry = described_class.new("https://example.com")
      expect {
        entry.priority = 1.1
      }.to raise_error(BetterSeo::ValidationError, /Priority must be between 0.0 and 1.0/)
    end
  end

  describe "#to_xml" do
    it "generates basic XML url entry" do
      entry = described_class.new("https://example.com/page")
      xml = entry.to_xml

      expect(xml).to include("<url>")
      expect(xml).to include("<loc>https://example.com/page</loc>")
      expect(xml).to include("<changefreq>weekly</changefreq>")
      expect(xml).to include("<priority>0.5</priority>")
      expect(xml).to include("</url>")
    end

    it "includes lastmod when present" do
      entry = described_class.new("https://example.com", lastmod: "2024-01-01")
      xml = entry.to_xml

      expect(xml).to include("<lastmod>2024-01-01</lastmod>")
    end

    it "excludes lastmod when not present" do
      entry = described_class.new("https://example.com")
      xml = entry.to_xml

      expect(xml).not_to include("<lastmod>")
    end

    it "generates properly indented XML" do
      entry = described_class.new("https://example.com")
      xml = entry.to_xml

      lines = xml.split("\n")
      expect(lines[0]).to match(/^\s{2}<url>/)
      expect(lines[1]).to match(/^\s{4}<loc>/)
      expect(lines[-1]).to match(/^\s{2}<\/url>/)
    end

    it "escapes special characters in URL" do
      entry = described_class.new("https://example.com/page?foo=bar&baz=qux")
      xml = entry.to_xml

      expect(xml).to include("&amp;")
      expect(xml).not_to include("&baz")
    end
  end

  describe "#to_h" do
    it "returns hash representation" do
      entry = described_class.new(
        "https://example.com",
        lastmod: "2024-01-01",
        changefreq: "daily",
        priority: 0.8
      )

      hash = entry.to_h
      expect(hash[:loc]).to eq("https://example.com")
      expect(hash[:lastmod]).to eq("2024-01-01")
      expect(hash[:changefreq]).to eq("daily")
      expect(hash[:priority]).to eq(0.8)
    end

    it "excludes nil values" do
      entry = described_class.new("https://example.com")
      hash = entry.to_h

      expect(hash.key?(:lastmod)).to be false
    end
  end

  describe "#validate!" do
    it "does not raise error for valid entry" do
      entry = described_class.new(
        "https://example.com",
        changefreq: "daily",
        priority: 0.5
      )

      expect { entry.validate! }.not_to raise_error
    end

    it "raises error when loc is missing" do
      entry = described_class.new("")
      expect {
        entry.validate!
      }.to raise_error(BetterSeo::ValidationError, /Location is required/)
    end

    it "raises error when loc is nil" do
      entry = described_class.new(nil)
      expect {
        entry.validate!
      }.to raise_error(BetterSeo::ValidationError, /Location is required/)
    end

    it "raises error for invalid URL format" do
      entry = described_class.new("not-a-url")
      expect {
        entry.validate!
      }.to raise_error(BetterSeo::ValidationError, /Invalid URL format/)
    end

    it "raises error for non-HTTP/HTTPS URLs" do
      entry = described_class.new("ftp://example.com/file")
      expect {
        entry.validate!
      }.to raise_error(BetterSeo::ValidationError, /Invalid URL format/)
    end
  end
end
