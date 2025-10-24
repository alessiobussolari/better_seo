# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::Sitemap::Builder do
  describe "#initialize" do
    it "creates builder with empty URL collection" do
      builder = described_class.new
      expect(builder.urls).to be_empty
    end

    it "accepts initial URLs" do
      urls = [
        BetterSeo::Sitemap::UrlEntry.new("https://example.com"),
        BetterSeo::Sitemap::UrlEntry.new("https://example.com/about")
      ]
      builder = described_class.new(urls: urls)
      expect(builder.urls.size).to eq(2)
    end
  end

  describe "#add_url" do
    it "adds URL entry with string location" do
      builder = described_class.new
      builder.add_url("https://example.com")
      expect(builder.urls.size).to eq(1)
      expect(builder.urls.first.loc).to eq("https://example.com")
    end

    it "adds URL entry with all attributes" do
      builder = described_class.new
      builder.add_url(
        "https://example.com",
        lastmod: "2024-01-01",
        changefreq: "daily",
        priority: 0.8
      )

      url = builder.urls.first
      expect(url.loc).to eq("https://example.com")
      expect(url.lastmod).to eq("2024-01-01")
      expect(url.changefreq).to eq("daily")
      expect(url.priority).to eq(0.8)
    end

    it "accepts Date object for lastmod" do
      builder = described_class.new
      date = Date.new(2024, 1, 1)
      builder.add_url("https://example.com", lastmod: date)

      expect(builder.urls.first.lastmod).to eq("2024-01-01")
    end

    it "returns self for method chaining" do
      builder = described_class.new
      result = builder.add_url("https://example.com")
      expect(result).to eq(builder)
    end

    it "allows chaining multiple add_url calls" do
      builder = described_class.new
      builder
        .add_url("https://example.com")
        .add_url("https://example.com/about")
        .add_url("https://example.com/contact")

      expect(builder.urls.size).to eq(3)
    end
  end

  describe "#add_urls" do
    it "adds multiple URLs at once from array of strings" do
      builder = described_class.new
      builder.add_urls([
        "https://example.com",
        "https://example.com/about",
        "https://example.com/contact"
      ])

      expect(builder.urls.size).to eq(3)
    end

    it "adds multiple URLs with same attributes" do
      builder = described_class.new
      builder.add_urls(
        ["https://example.com", "https://example.com/about"],
        changefreq: "daily",
        priority: 0.8
      )

      builder.urls.each do |url|
        expect(url.changefreq).to eq("daily")
        expect(url.priority).to eq(0.8)
      end
    end

    it "returns self for method chaining" do
      builder = described_class.new
      result = builder.add_urls(["https://example.com"])
      expect(result).to eq(builder)
    end
  end

  describe "#remove_url" do
    it "removes URL by location string" do
      builder = described_class.new
      builder.add_url("https://example.com")
      builder.add_url("https://example.com/about")

      builder.remove_url("https://example.com")
      expect(builder.urls.size).to eq(1)
      expect(builder.urls.first.loc).to eq("https://example.com/about")
    end

    it "returns self for method chaining" do
      builder = described_class.new
      builder.add_url("https://example.com")
      result = builder.remove_url("https://example.com")
      expect(result).to eq(builder)
    end

    it "does nothing if URL not found" do
      builder = described_class.new
      builder.add_url("https://example.com")

      expect {
        builder.remove_url("https://other.com")
      }.not_to change { builder.urls.size }
    end
  end

  describe "#clear" do
    it "removes all URLs" do
      builder = described_class.new
      builder.add_url("https://example.com")
      builder.add_url("https://example.com/about")

      builder.clear
      expect(builder.urls).to be_empty
    end

    it "returns self for method chaining" do
      builder = described_class.new
      result = builder.clear
      expect(result).to eq(builder)
    end
  end

  describe "#to_xml" do
    it "generates complete sitemap XML" do
      builder = described_class.new
      builder.add_url("https://example.com")

      xml = builder.to_xml

      expect(xml).to include('<?xml version="1.0" encoding="UTF-8"?>')
      expect(xml).to include('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">')
      expect(xml).to include("<loc>https://example.com</loc>")
      expect(xml).to include("</urlset>")
    end

    it "includes all URL entries" do
      builder = described_class.new
      builder.add_url("https://example.com")
      builder.add_url("https://example.com/about")

      xml = builder.to_xml

      expect(xml).to include("<loc>https://example.com</loc>")
      expect(xml).to include("<loc>https://example.com/about</loc>")
    end

    it "generates empty sitemap when no URLs" do
      builder = described_class.new
      xml = builder.to_xml

      expect(xml).to include('<?xml version="1.0" encoding="UTF-8"?>')
      expect(xml).to include('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">')
      expect(xml).to include("</urlset>")
      expect(xml).not_to include("<url>")
    end

    it "properly indents XML structure" do
      builder = described_class.new
      builder.add_url("https://example.com")

      xml = builder.to_xml
      lines = xml.split("\n")

      expect(lines[0]).to eq('<?xml version="1.0" encoding="UTF-8"?>')
      expect(lines[1]).to match(/<urlset/)
      expect(lines[2]).to match(/^\s{2}<url>/)
      expect(lines[-1]).to eq("</urlset>")
    end
  end

  describe "#validate!" do
    it "validates all URL entries" do
      builder = described_class.new
      builder.add_url("https://example.com")
      builder.add_url("https://example.com/about")

      expect { builder.validate! }.not_to raise_error
    end

    it "raises error if any URL is invalid" do
      builder = described_class.new
      builder.add_url("https://example.com")
      builder.add_url("not-a-url")

      expect {
        builder.validate!
      }.to raise_error(BetterSeo::ValidationError, /Invalid URL format/)
    end

    it "raises error if URL is missing" do
      builder = described_class.new
      builder.add_url("")

      expect {
        builder.validate!
      }.to raise_error(BetterSeo::ValidationError, /Location is required/)
    end

    it "returns true when all URLs are valid" do
      builder = described_class.new
      builder.add_url("https://example.com")

      expect(builder.validate!).to be true
    end
  end

  describe "#size" do
    it "returns number of URLs" do
      builder = described_class.new
      expect(builder.size).to eq(0)

      builder.add_url("https://example.com")
      expect(builder.size).to eq(1)

      builder.add_url("https://example.com/about")
      expect(builder.size).to eq(2)
    end
  end

  describe "#empty?" do
    it "returns true when no URLs" do
      builder = described_class.new
      expect(builder).to be_empty
    end

    it "returns false when URLs exist" do
      builder = described_class.new
      builder.add_url("https://example.com")
      expect(builder).not_to be_empty
    end
  end

  describe "#each" do
    it "iterates over all URLs" do
      builder = described_class.new
      builder.add_url("https://example.com")
      builder.add_url("https://example.com/about")

      urls = []
      builder.each do |url|
        urls << url.loc
      end

      expect(urls).to eq(["https://example.com", "https://example.com/about"])
    end

    it "returns enumerator when no block given" do
      builder = described_class.new
      builder.add_url("https://example.com")

      enumerator = builder.each
      expect(enumerator).to be_a(Enumerator)
      expect(enumerator.to_a.size).to eq(1)
    end
  end
end
