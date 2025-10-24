# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::DSL::OpenGraph do
  subject(:og) { described_class.new }

  describe "#initialize" do
    it "inherits from Base" do
      expect(og).to be_a(BetterSeo::DSL::Base)
    end

    it "starts with empty config" do
      expect(og.config).to eq({})
    end
  end

  describe "#title" do
    it "sets and gets title" do
      og.title("My OG Title")
      expect(og.title).to eq("My OG Title")
    end

    it "returns nil if not set" do
      expect(og.title).to be_nil
    end

    it "returns self for chaining" do
      expect(og.title("Title")).to eq(og)
    end
  end

  describe "#description" do
    it "sets and gets description" do
      og.description("My OG Description")
      expect(og.description).to eq("My OG Description")
    end
  end

  describe "#type" do
    it "sets and gets type" do
      og.type("article")
      expect(og.type).to eq("article")
    end

    it "defaults to website" do
      expect(og.type).to be_nil  # Will be set from config defaults
    end
  end

  describe "#url" do
    it "sets and gets URL" do
      og.url("https://example.com/page")
      expect(og.url).to eq("https://example.com/page")
    end
  end

  describe "#image" do
    context "with simple URL string" do
      it "sets image as string" do
        og.image("https://example.com/image.jpg")
        expect(og.get(:image)).to eq("https://example.com/image.jpg")
      end
    end

    context "with hash configuration" do
      it "sets image with full configuration" do
        og.image(url: "https://example.com/image.jpg", width: 1200, height: 630, alt: "Image Alt")
        expect(og.get(:image)).to eq({
          url: "https://example.com/image.jpg",
          width: 1200,
          height: 630,
          alt: "Image Alt"
        })
      end

      it "sets image with partial configuration" do
        og.image(url: "https://example.com/image.jpg")
        expect(og.get(:image)[:url]).to eq("https://example.com/image.jpg")
      end
    end

    context "when getting value" do
      it "returns image without argument" do
        og.set(:image, "https://example.com/stored.jpg")
        expect(og.image).to eq("https://example.com/stored.jpg")
      end
    end
  end

  describe "#site_name" do
    it "sets and gets site_name" do
      og.site_name("My Website")
      expect(og.site_name).to eq("My Website")
    end
  end

  describe "#locale" do
    it "sets and gets locale" do
      og.locale("en_US")
      expect(og.locale).to eq("en_US")
    end

    it "accepts symbol" do
      og.locale(:it_IT)
      expect(og.locale).to eq(:it_IT)
    end
  end

  describe "#locale_alternate" do
    it "sets alternative locales as array" do
      og.locale_alternate("fr_FR", "de_DE")
      expect(og.get(:locale_alternate)).to eq(["fr_FR", "de_DE"])
    end

    it "flattens nested arrays" do
      og.locale_alternate(["fr_FR", "de_DE"], "es_ES")
      expect(og.get(:locale_alternate)).to eq(["fr_FR", "de_DE", "es_ES"])
    end
  end

  describe "article properties" do
    describe "#article" do
      it "sets article properties with block" do
        og.article do
          author "John Doe"
          published_time "2024-01-01T00:00:00Z"
          modified_time "2024-01-02T00:00:00Z"
          expiration_time "2024-12-31T23:59:59Z"
          section "Technology"
          tag "Ruby", "Rails", "SEO"
        end

        article_data = og.get(:article)
        expect(article_data[:author]).to eq("John Doe")
        expect(article_data[:published_time]).to eq("2024-01-01T00:00:00Z")
        expect(article_data[:modified_time]).to eq("2024-01-02T00:00:00Z")
        expect(article_data[:expiration_time]).to eq("2024-12-31T23:59:59Z")
        expect(article_data[:section]).to eq("Technology")
        expect(article_data[:tag]).to eq(["Ruby", "Rails", "SEO"])
      end

      it "returns article data without block" do
        og.set(:article, { author: "Jane Doe", section: "Tech" })
        expect(og.article).to eq({ author: "Jane Doe", section: "Tech" })
      end
    end
  end

  describe "#video" do
    it "sets video URL" do
      og.video("https://example.com/video.mp4")
      expect(og.video).to eq("https://example.com/video.mp4")
    end

    it "sets video with configuration hash" do
      og.video(url: "https://example.com/video.mp4", width: 1920, height: 1080, type: "video/mp4")
      expect(og.get(:video)).to eq({
        url: "https://example.com/video.mp4",
        width: 1920,
        height: 1080,
        type: "video/mp4"
      })
    end
  end

  describe "#audio" do
    it "sets audio URL" do
      og.audio("https://example.com/audio.mp3")
      expect(og.audio).to eq("https://example.com/audio.mp3")
    end
  end

  describe "#build" do
    it "returns complete configuration" do
      og.evaluate do
        title "OG Test Title"
        description "OG Test Description"
        type "article"
        url "https://example.com/test"
        image "https://example.com/image.jpg"
        site_name "Test Site"
        locale "en_US"
      end

      result = og.build

      expect(result[:title]).to eq("OG Test Title")
      expect(result[:description]).to eq("OG Test Description")
      expect(result[:type]).to eq("article")
      expect(result[:url]).to eq("https://example.com/test")
      expect(result[:image]).to eq("https://example.com/image.jpg")
      expect(result[:site_name]).to eq("Test Site")
      expect(result[:locale]).to eq("en_US")
    end
  end

  describe "#validate!" do
    context "with valid data" do
      it "does not raise error with required fields" do
        og.title("Valid Title")
        og.type("website")
        og.image("https://example.com/image.jpg")
        og.url("https://example.com")

        expect { og.send(:validate!) }.not_to raise_error
      end
    end

    context "with invalid data" do
      it "raises error when title is missing" do
        og.type("website")
        og.image("https://example.com/image.jpg")
        og.url("https://example.com")

        expect {
          og.send(:validate!)
        }.to raise_error(BetterSeo::ValidationError, /title is required/)
      end

      it "raises error when type is missing" do
        og.title("Title")
        og.image("https://example.com/image.jpg")
        og.url("https://example.com")

        expect {
          og.send(:validate!)
        }.to raise_error(BetterSeo::ValidationError, /type is required/)
      end

      it "raises error when image is missing" do
        og.title("Title")
        og.type("website")
        og.url("https://example.com")

        expect {
          og.send(:validate!)
        }.to raise_error(BetterSeo::ValidationError, /image is required/)
      end

      it "raises error when url is missing" do
        og.title("Title")
        og.type("website")
        og.image("https://example.com/image.jpg")

        expect {
          og.send(:validate!)
        }.to raise_error(BetterSeo::ValidationError, /url is required/)
      end

      it "raises multiple errors" do
        expect {
          og.send(:validate!)
        }.to raise_error(BetterSeo::ValidationError, /title.*type.*image.*url/)
      end
    end
  end

  describe "method chaining" do
    it "supports fluent interface" do
      result = og
        .title("Chained Title")
        .description("Chained Description")
        .type("article")
        .url("https://example.com/chain")
        .image("https://example.com/chain.jpg")
        .site_name("Chained Site")
        .locale("en_US")

      expect(result).to eq(og)
      expect(og.title).to eq("Chained Title")
      expect(og.description).to eq("Chained Description")
      expect(og.type).to eq("article")
    end
  end
end
