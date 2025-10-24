# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::Sitemap::Generator do
  describe ".generate" do
    it "generates sitemap from block" do
      xml = described_class.generate do |sitemap|
        sitemap.add_url("https://example.com")
        sitemap.add_url("https://example.com/about")
      end

      expect(xml).to include('<?xml version="1.0" encoding="UTF-8"?>')
      expect(xml).to include("<loc>https://example.com</loc>")
      expect(xml).to include("<loc>https://example.com/about</loc>")
    end

    it "generates sitemap with URL options" do
      xml = described_class.generate do |sitemap|
        sitemap.add_url(
          "https://example.com",
          lastmod: "2024-01-01",
          changefreq: "daily",
          priority: 0.9
        )
      end

      expect(xml).to include("<lastmod>2024-01-01</lastmod>")
      expect(xml).to include("<changefreq>daily</changefreq>")
      expect(xml).to include("<priority>0.9</priority>")
    end

    it "returns XML string" do
      xml = described_class.generate do |sitemap|
        sitemap.add_url("https://example.com")
      end

      expect(xml).to be_a(String)
      expect(xml).to include("</urlset>")
    end

    it "generates empty sitemap when no URLs added" do
      xml = described_class.generate do |sitemap|
        # No URLs added
      end

      expect(xml).to include('<?xml version="1.0" encoding="UTF-8"?>')
      expect(xml).to include('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">')
      expect(xml).not_to include("<url>")
    end
  end

  describe ".generate_from" do
    it "generates sitemap from array of URLs" do
      urls = [
        "https://example.com",
        "https://example.com/about",
        "https://example.com/contact"
      ]

      xml = described_class.generate_from(urls)

      expect(xml).to include("<loc>https://example.com</loc>")
      expect(xml).to include("<loc>https://example.com/about</loc>")
      expect(xml).to include("<loc>https://example.com/contact</loc>")
    end

    it "accepts URL options" do
      urls = ["https://example.com", "https://example.com/about"]

      xml = described_class.generate_from(
        urls,
        changefreq: "daily",
        priority: 0.8
      )

      expect(xml).to include("<changefreq>daily</changefreq>")
      expect(xml).to include("<priority>0.8</priority>")
    end

    it "accepts lastmod option" do
      urls = ["https://example.com"]

      xml = described_class.generate_from(
        urls,
        lastmod: "2024-01-01"
      )

      expect(xml).to include("<lastmod>2024-01-01</lastmod>")
    end

    it "generates empty sitemap from empty array" do
      xml = described_class.generate_from([])

      expect(xml).to include('<?xml version="1.0" encoding="UTF-8"?>')
      expect(xml).not_to include("<url>")
    end
  end

  describe ".generate_from_collection" do
    let(:model_class) do
      Class.new do
        attr_reader :slug, :updated_at

        def initialize(slug, updated_at)
          @slug = slug
          @updated_at = updated_at
        end

        def self.all
          [
            new("post-1", Time.new(2024, 1, 1)),
            new("post-2", Time.new(2024, 1, 2)),
            new("post-3", Time.new(2024, 1, 3))
          ]
        end
      end
    end

    it "generates sitemap from model collection with URL generator" do
      xml = described_class.generate_from_collection(
        model_class.all,
        url: ->(item) { "https://example.com/posts/#{item.slug}" }
      )

      expect(xml).to include("<loc>https://example.com/posts/post-1</loc>")
      expect(xml).to include("<loc>https://example.com/posts/post-2</loc>")
      expect(xml).to include("<loc>https://example.com/posts/post-3</loc>")
    end

    it "generates sitemap with lastmod from model attribute" do
      xml = described_class.generate_from_collection(
        model_class.all,
        url: ->(item) { "https://example.com/posts/#{item.slug}" },
        lastmod: lambda(&:updated_at)
      )

      expect(xml).to include("<lastmod>2024-01-01</lastmod>")
      expect(xml).to include("<lastmod>2024-01-02</lastmod>")
      expect(xml).to include("<lastmod>2024-01-03</lastmod>")
    end

    it "accepts static changefreq and priority" do
      xml = described_class.generate_from_collection(
        model_class.all,
        url: ->(item) { "https://example.com/posts/#{item.slug}" },
        changefreq: "weekly",
        priority: 0.7
      )

      lines = xml.split("\n")
      changefreq_count = lines.count { |line| line.include?("<changefreq>weekly</changefreq>") }
      priority_count = lines.count { |line| line.include?("<priority>0.7</priority>") }

      expect(changefreq_count).to eq(3)
      expect(priority_count).to eq(3)
    end

    it "accepts dynamic changefreq and priority" do
      xml = described_class.generate_from_collection(
        model_class.all,
        url: ->(item) { "https://example.com/posts/#{item.slug}" },
        changefreq: ->(item) { item.slug == "post-1" ? "daily" : "weekly" },
        priority: ->(item) { item.slug == "post-1" ? 0.9 : 0.5 }
      )

      expect(xml).to include("<changefreq>daily</changefreq>")
      expect(xml).to include("<changefreq>weekly</changefreq>")
      expect(xml).to include("<priority>0.9</priority>")
      expect(xml).to include("<priority>0.5</priority>")
    end

    it "raises error when url option is missing" do
      expect do
        described_class.generate_from_collection(model_class.all)
      end.to raise_error(ArgumentError, /url option is required/)
    end

    it "raises error when url option is not callable" do
      expect do
        described_class.generate_from_collection(
          model_class.all,
          url: "not-a-proc"
        )
      end.to raise_error(ArgumentError, /url option must be callable/)
    end

    it "generates empty sitemap from empty collection" do
      xml = described_class.generate_from_collection(
        [],
        url: ->(item) { "https://example.com/#{item}" }
      )

      expect(xml).to include('<?xml version="1.0" encoding="UTF-8"?>')
      expect(xml).not_to include("<url>")
    end
  end

  describe ".write_to_file" do
    let(:temp_file) { "/tmp/sitemap_test_#{Time.now.to_i}.xml" }

    after do
      FileUtils.rm_f(temp_file)
    end

    it "writes sitemap XML to file" do
      described_class.write_to_file(temp_file) do |sitemap|
        sitemap.add_url("https://example.com")
      end

      expect(File.exist?(temp_file)).to be true
      content = File.read(temp_file)
      expect(content).to include("<loc>https://example.com</loc>")
    end

    it "creates parent directories if they don't exist" do
      nested_file = "/tmp/sitemap_test_#{Time.now.to_i}/nested/sitemap.xml"

      begin
        described_class.write_to_file(nested_file) do |sitemap|
          sitemap.add_url("https://example.com")
        end

        expect(File.exist?(nested_file)).to be true
      ensure
        FileUtils.rm_rf(File.dirname(File.dirname(nested_file)))
      end
    end

    it "returns the file path" do
      result = described_class.write_to_file(temp_file) do |sitemap|
        sitemap.add_url("https://example.com")
      end

      expect(result).to eq(temp_file)
    end
  end
end
