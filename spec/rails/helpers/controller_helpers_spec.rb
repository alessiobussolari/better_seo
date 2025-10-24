# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::Rails::Helpers::ControllerHelpers do
  let(:controller) do
    Class.new do
      include BetterSeo::Rails::Helpers::ControllerHelpers

      attr_accessor :_better_seo_data

      def initialize
        @_better_seo_data = {}
      end
    end.new
  end

  describe "#set_meta_tags" do
    it "sets meta tags data" do
      controller.set_meta_tags(
        title: "My Page",
        description: "Page description",
        keywords: ["ruby", "rails"]
      )

      data = controller.better_seo_data
      expect(data[:meta][:title]).to eq("My Page")
      expect(data[:meta][:description]).to eq("Page description")
      expect(data[:meta][:keywords]).to eq(["ruby", "rails"])
    end

    it "supports block syntax" do
      controller.set_meta_tags do |meta|
        meta[:title] = "Block Title"
        meta[:description] = "Block Description"
      end

      expect(controller.better_seo_data[:meta][:title]).to eq("Block Title")
    end

    it "merges with existing data" do
      controller.set_meta_tags(title: "First Title")
      controller.set_meta_tags(description: "First Description")

      data = controller.better_seo_data[:meta]
      expect(data[:title]).to eq("First Title")
      expect(data[:description]).to eq("First Description")
    end
  end

  describe "#set_og_tags" do
    it "sets Open Graph tags data" do
      controller.set_og_tags(
        title: "OG Title",
        type: "article",
        url: "https://example.com/article"
      )

      data = controller.better_seo_data
      expect(data[:og][:title]).to eq("OG Title")
      expect(data[:og][:type]).to eq("article")
      expect(data[:og][:url]).to eq("https://example.com/article")
    end

    it "supports block syntax" do
      controller.set_og_tags do |og|
        og[:title] = "Block OG Title"
        og[:type] = "website"
      end

      expect(controller.better_seo_data[:og][:title]).to eq("Block OG Title")
    end
  end

  describe "#set_twitter_tags" do
    it "sets Twitter Card tags data" do
      controller.set_twitter_tags(
        card: "summary_large_image",
        title: "Twitter Title",
        description: "Twitter Description"
      )

      data = controller.better_seo_data
      expect(data[:twitter][:card]).to eq("summary_large_image")
      expect(data[:twitter][:title]).to eq("Twitter Title")
      expect(data[:twitter][:description]).to eq("Twitter Description")
    end

    it "supports block syntax" do
      controller.set_twitter_tags do |twitter|
        twitter[:card] = "summary"
        twitter[:title] = "Block Twitter Title"
      end

      expect(controller.better_seo_data[:twitter][:card]).to eq("summary")
    end
  end

  describe "#set_canonical" do
    it "sets canonical URL" do
      controller.set_canonical("https://example.com/canonical")

      expect(controller.better_seo_data[:meta][:canonical]).to eq("https://example.com/canonical")
    end

    it "overwrites previous canonical" do
      controller.set_canonical("https://example.com/first")
      controller.set_canonical("https://example.com/second")

      expect(controller.better_seo_data[:meta][:canonical]).to eq("https://example.com/second")
    end
  end

  describe "#set_page_title" do
    it "sets page title" do
      controller.set_page_title("My Page Title")

      expect(controller.better_seo_data[:meta][:title]).to eq("My Page Title")
    end

    it "sets title with suffix" do
      controller.set_page_title("My Page", suffix: " | My Site")

      expect(controller.better_seo_data[:meta][:title]).to eq("My Page | My Site")
    end

    it "sets title with prefix" do
      controller.set_page_title("My Page", prefix: "My Site | ")

      expect(controller.better_seo_data[:meta][:title]).to eq("My Site | My Page")
    end

    it "sets title with both prefix and suffix" do
      controller.set_page_title("My Page", prefix: "Start | ", suffix: " | End")

      expect(controller.better_seo_data[:meta][:title]).to eq("Start | My Page | End")
    end
  end

  describe "#set_page_description" do
    it "sets page description" do
      controller.set_page_description("This is my page description")

      expect(controller.better_seo_data[:meta][:description]).to eq("This is my page description")
    end

    it "truncates long descriptions" do
      long_desc = "a" * 200
      controller.set_page_description(long_desc, max_length: 160)

      result = controller.better_seo_data[:meta][:description]
      expect(result.length).to be <= 160
      expect(result).to end_with("...")
    end

    it "does not truncate if within limit" do
      desc = "Short description"
      controller.set_page_description(desc, max_length: 160)

      expect(controller.better_seo_data[:meta][:description]).to eq(desc)
    end
  end

  describe "#set_page_keywords" do
    it "sets page keywords from array" do
      controller.set_page_keywords(["ruby", "rails", "seo"])

      expect(controller.better_seo_data[:meta][:keywords]).to eq(["ruby", "rails", "seo"])
    end

    it "sets page keywords from comma-separated string" do
      controller.set_page_keywords("ruby, rails, seo")

      expect(controller.better_seo_data[:meta][:keywords]).to eq(["ruby", "rails", "seo"])
    end
  end

  describe "#set_page_image" do
    it "sets page image for OG and Twitter" do
      controller.set_page_image("https://example.com/image.jpg")

      expect(controller.better_seo_data[:og][:image]).to eq("https://example.com/image.jpg")
      expect(controller.better_seo_data[:twitter][:image]).to eq("https://example.com/image.jpg")
    end

    it "sets image with dimensions" do
      controller.set_page_image(
        "https://example.com/image.jpg",
        width: 1200,
        height: 630
      )

      og_data = controller.better_seo_data[:og]
      expect(og_data[:image]).to eq("https://example.com/image.jpg")
      expect(og_data[:image_width]).to eq(1200)
      expect(og_data[:image_height]).to eq(630)
    end
  end

  describe "#set_noindex" do
    it "sets noindex robot directive" do
      controller.set_noindex

      expect(controller.better_seo_data[:meta][:robots]).to eq("noindex")
    end

    it "sets noindex, nofollow" do
      controller.set_noindex(nofollow: true)

      expect(controller.better_seo_data[:meta][:robots]).to eq("noindex, nofollow")
    end
  end

  describe "#better_seo_data" do
    it "returns empty hash by default" do
      expect(controller.better_seo_data).to eq({})
    end

    it "returns stored SEO data" do
      controller.set_meta_tags(title: "Test")
      controller.set_og_tags(title: "OG Test")

      data = controller.better_seo_data
      expect(data[:meta][:title]).to eq("Test")
      expect(data[:og][:title]).to eq("OG Test")
    end

    it "initializes nested hashes automatically" do
      controller.set_meta_tags(title: "Test")

      data = controller.better_seo_data
      expect(data[:meta]).to be_a(Hash)
      expect(data[:og]).to be_nil
    end
  end

  describe "integration example" do
    it "sets complete SEO data for a page" do
      controller.set_page_title("My Article", suffix: " | My Blog")
      controller.set_page_description("This is an amazing article about Ruby")
      controller.set_page_keywords(["ruby", "programming", "tutorial"])
      controller.set_page_image("https://example.com/article-image.jpg", width: 1200, height: 630)
      controller.set_canonical("https://example.com/articles/my-article")

      controller.set_og_tags do |og|
        og[:type] = "article"
        og[:locale] = "en_US"
      end

      controller.set_twitter_tags(card: "summary_large_image")

      data = controller.better_seo_data

      # Meta tags
      expect(data[:meta][:title]).to eq("My Article | My Blog")
      expect(data[:meta][:description]).to eq("This is an amazing article about Ruby")
      expect(data[:meta][:keywords]).to eq(["ruby", "programming", "tutorial"])
      expect(data[:meta][:canonical]).to eq("https://example.com/articles/my-article")

      # OG tags
      expect(data[:og][:image]).to eq("https://example.com/article-image.jpg")
      expect(data[:og][:image_width]).to eq(1200)
      expect(data[:og][:image_height]).to eq(630)
      expect(data[:og][:type]).to eq("article")
      expect(data[:og][:locale]).to eq("en_US")

      # Twitter tags
      expect(data[:twitter][:card]).to eq("summary_large_image")
      expect(data[:twitter][:image]).to eq("https://example.com/article-image.jpg")
    end
  end
end
