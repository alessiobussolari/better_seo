# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::Sitemap::SitemapIndex do
  describe "initialization" do
    it "creates empty sitemap index" do
      index = described_class.new
      expect(index.sitemaps).to eq([])
    end
  end

  describe "#add_sitemap" do
    let(:index) { described_class.new }

    it "adds a sitemap with location" do
      index.add_sitemap("https://example.com/sitemap1.xml")

      expect(index.sitemaps.size).to eq(1)
      expect(index.sitemaps[0][:loc]).to eq("https://example.com/sitemap1.xml")
    end

    it "adds a sitemap with location and lastmod" do
      index.add_sitemap("https://example.com/sitemap1.xml", lastmod: "2024-01-15")

      sitemap = index.sitemaps.first
      expect(sitemap[:loc]).to eq("https://example.com/sitemap1.xml")
      expect(sitemap[:lastmod]).to eq("2024-01-15")
    end

    it "supports Date object for lastmod" do
      index.add_sitemap("https://example.com/sitemap1.xml", lastmod: Date.new(2024, 1, 15))

      expect(index.sitemaps.first[:lastmod]).to eq("2024-01-15")
    end

    it "supports Time object for lastmod" do
      time = Time.new(2024, 1, 15, 10, 30, 0, "+00:00")
      index.add_sitemap("https://example.com/sitemap1.xml", lastmod: time)

      expect(index.sitemaps.first[:lastmod]).to eq("2024-01-15")
    end

    it "supports method chaining" do
      index.add_sitemap("https://example.com/sitemap1.xml")
        .add_sitemap("https://example.com/sitemap2.xml")
        .add_sitemap("https://example.com/sitemap3.xml")

      expect(index.sitemaps.size).to eq(3)
    end
  end

  describe "#to_xml" do
    it "generates valid sitemap index XML" do
      index = described_class.new
      index.add_sitemap("https://example.com/sitemap1.xml", lastmod: "2024-01-15")
      index.add_sitemap("https://example.com/sitemap2.xml", lastmod: "2024-01-20")

      xml = index.to_xml

      expect(xml).to include('<?xml version="1.0" encoding="UTF-8"?>')
      expect(xml).to include('<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">')
      expect(xml).to include("<sitemap>")
      expect(xml).to include("<loc>https://example.com/sitemap1.xml</loc>")
      expect(xml).to include("<lastmod>2024-01-15</lastmod>")
      expect(xml).to include("<loc>https://example.com/sitemap2.xml</loc>")
      expect(xml).to include("<lastmod>2024-01-20</lastmod>")
      expect(xml).to include("</sitemap>")
      expect(xml).to include("</sitemapindex>")
    end

    it "generates XML without lastmod when not provided" do
      index = described_class.new
      index.add_sitemap("https://example.com/sitemap1.xml")

      xml = index.to_xml

      expect(xml).to include("<loc>https://example.com/sitemap1.xml</loc>")
      expect(xml).not_to include("<lastmod>")
    end

    it "escapes special XML characters in URLs" do
      index = described_class.new
      index.add_sitemap("https://example.com/sitemap?page=1&lang=en")

      xml = index.to_xml

      expect(xml).to include("https://example.com/sitemap?page=1&amp;lang=en")
    end
  end

  describe "#write_to_file" do
    let(:index) { described_class.new }
    let(:test_file) { "/tmp/sitemap_index_test.xml" }

    after { File.delete(test_file) if File.exist?(test_file) }

    it "writes sitemap index to file" do
      index.add_sitemap("https://example.com/sitemap1.xml")
      index.add_sitemap("https://example.com/sitemap2.xml")

      index.write_to_file(test_file)

      expect(File.exist?(test_file)).to be true
      content = File.read(test_file)
      expect(content).to include("<sitemapindex")
      expect(content).to include("sitemap1.xml")
      expect(content).to include("sitemap2.xml")
    end

    it "creates directory if it doesn't exist" do
      nested_file = "/tmp/nested_dir/sitemap_index_test.xml"
      index.add_sitemap("https://example.com/sitemap1.xml")

      index.write_to_file(nested_file)

      expect(File.exist?(nested_file)).to be true
      FileUtils.rm_rf("/tmp/nested_dir")
    end
  end

  describe "complete example with multiple sitemaps" do
    it "creates sitemap index for large site" do
      index = described_class.new

      # Add sitemaps for different sections
      index.add_sitemap("https://example.com/sitemap-articles-1.xml", lastmod: Date.new(2024, 1, 15))
      index.add_sitemap("https://example.com/sitemap-articles-2.xml", lastmod: Date.new(2024, 1, 16))
      index.add_sitemap("https://example.com/sitemap-products-1.xml", lastmod: Date.new(2024, 1, 17))
      index.add_sitemap("https://example.com/sitemap-products-2.xml", lastmod: Date.new(2024, 1, 18))
      index.add_sitemap("https://example.com/sitemap-categories.xml", lastmod: Date.new(2024, 1, 19))

      expect(index.sitemaps.size).to eq(5)

      xml = index.to_xml

      expect(xml).to include("sitemap-articles-1.xml")
      expect(xml).to include("sitemap-articles-2.xml")
      expect(xml).to include("sitemap-products-1.xml")
      expect(xml).to include("sitemap-products-2.xml")
      expect(xml).to include("sitemap-categories.xml")

      expect(xml.scan(/<sitemap>/).size).to eq(5)
      expect(xml.scan(/<\/sitemap>/).size).to eq(5)
    end
  end
end
