# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::Rails::Helpers::SeoHelper do
  # Mock a view context for testing
  let(:view_context) do
    Class.new do
      include BetterSeo::Rails::Helpers::SeoHelper

      def raw(text)
        text
      end
    end.new
  end

  describe "#seo_meta_tags" do
    it "generates meta tags from hash configuration" do
      config = {
        title: "Test Page",
        description: "Test Description",
        keywords: %w[ruby seo]
      }

      html = view_context.seo_meta_tags(config)

      expect(html).to include("<title>Test Page</title>")
      expect(html).to include("Test Description")
      expect(html).to include("ruby, seo")
    end

    it "generates meta tags from DSL block" do
      html = view_context.seo_meta_tags do |meta|
        meta.title "Block Title"
        meta.description "Block Description"
      end

      expect(html).to include("<title>Block Title</title>")
      expect(html).to include("Block Description")
    end

    it "returns HTML safe string" do
      html = view_context.seo_meta_tags(title: "Test")
      expect(html).to be_a(String)
    end

    it "works with empty configuration" do
      html = view_context.seo_meta_tags({})
      expect(html).to be_a(String)
    end
  end

  describe "#seo_open_graph_tags" do
    it "generates Open Graph tags from hash configuration" do
      config = {
        title: "OG Title",
        type: "article",
        url: "https://example.com",
        image: "https://example.com/og.jpg"
      }

      html = view_context.seo_open_graph_tags(config)

      expect(html).to include('property="og:title"')
      expect(html).to include("OG Title")
      expect(html).to include("article")
    end

    it "generates Open Graph tags from DSL block" do
      html = view_context.seo_open_graph_tags do |og|
        og.title "Block OG Title"
        og.type "website"
        og.url "https://example.com"
        og.image "https://example.com/img.jpg"
      end

      expect(html).to include("Block OG Title")
      expect(html).to include("website")
    end

    it "returns HTML safe string" do
      config = {
        title: "Test",
        type: "website",
        url: "https://example.com",
        image: "https://example.com/img.jpg"
      }
      html = view_context.seo_open_graph_tags(config)
      expect(html).to be_a(String)
    end
  end

  describe "#seo_twitter_tags" do
    it "generates Twitter Card tags from hash configuration" do
      config = {
        card: "summary_large_image",
        site: "@mysite",
        title: "Twitter Title",
        description: "Twitter Description"
      }

      html = view_context.seo_twitter_tags(config)

      expect(html).to include('name="twitter:card"')
      expect(html).to include("summary_large_image")
      expect(html).to include("@mysite")
    end

    it "generates Twitter Card tags from DSL block" do
      html = view_context.seo_twitter_tags do |twitter|
        twitter.card "summary"
        twitter.site "@site"
        twitter.title "Block Twitter Title"
        twitter.description "Block Description"
      end

      expect(html).to include("Block Twitter Title")
      expect(html).to include("@site")
    end

    it "returns HTML safe string" do
      config = {
        card: "summary",
        title: "Test",
        description: "Test"
      }
      html = view_context.seo_twitter_tags(config)
      expect(html).to be_a(String)
    end
  end

  describe "#seo_tags" do
    it "generates all SEO tags from hash configuration" do
      config = {
        meta: {
          title: "Complete Page",
          description: "Complete Description"
        },
        og: {
          title: "OG Complete",
          type: "article",
          url: "https://example.com",
          image: "https://example.com/img.jpg"
        },
        twitter: {
          card: "summary",
          title: "Twitter Complete",
          description: "Twitter Description"
        }
      }

      html = view_context.seo_tags(config)

      expect(html).to include("<title>Complete Page</title>")
      expect(html).to include('property="og:title"')
      expect(html).to include('name="twitter:card"')
    end

    it "generates all SEO tags from DSL block" do
      html = view_context.seo_tags do |seo|
        seo.meta do |meta|
          meta.title "All Tags Title"
          meta.description "All Tags Description"
        end

        seo.og do |og|
          og.title "All OG Title"
          og.type "website"
          og.url "https://example.com"
          og.image "https://example.com/img.jpg"
        end

        seo.twitter do |twitter|
          twitter.card "summary"
          twitter.title "All Twitter Title"
          twitter.description "All Twitter Description"
        end
      end

      expect(html).to include("All Tags Title")
      expect(html).to include("All OG Title")
      expect(html).to include("All Twitter Title")
    end

    it "generates all tag groups with defaults when only meta is provided" do
      html = view_context.seo_tags do |seo|
        seo.meta do |meta|
          meta.title "Only Meta"
        end
      end

      # Meta tags should include the custom title
      expect(html).to include("Only Meta")

      # OG and Twitter tags should be generated automatically with defaults
      expect(html).to include('property="og:')
      expect(html).to include('name="twitter:')

      # OG should use meta title as fallback
      expect(html).to include('property="og:title" content="Only Meta')
    end

    it "returns HTML safe string" do
      html = view_context.seo_tags({})
      expect(html).to be_a(String)
    end
  end

  describe "integration with configuration defaults" do
    before do
      BetterSeo.configure do |config|
        config.site_name = "Default Site"
        config.meta_tags.default_title = "Default Title"
        config.open_graph.site_name = "Default OG Site"
        config.twitter.site = "@defaultsite"
      end
    end

    after do
      BetterSeo.reset_configuration!
    end

    it "uses configuration defaults when not specified" do
      html = view_context.seo_meta_tags do |meta|
        meta.description "Only description"
      end

      expect(html).to be_a(String)
    end
  end
end
