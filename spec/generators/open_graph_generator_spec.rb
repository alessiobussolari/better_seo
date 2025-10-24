# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::Generators::OpenGraphGenerator do
  let(:config) do
    {
      title: "My Open Graph Title",
      description: "Description for social media sharing",
      type: "article",
      url: "https://example.com/article",
      image: "https://example.com/og-image.jpg",
      site_name: "My Awesome Site",
      locale: "en_US",
      locale_alternate: ["it_IT", "fr_FR"]
    }
  end

  subject(:generator) { described_class.new(config) }

  describe "#initialize" do
    it "accepts configuration hash" do
      expect(generator.instance_variable_get(:@config)).to eq(config)
    end
  end

  describe "#generate" do
    let(:html) { generator.generate }

    it "returns a string" do
      expect(html).to be_a(String)
    end

    it "generates og:title meta tag" do
      expect(html).to include('<meta property="og:title" content="My Open Graph Title">')
    end

    it "generates og:description meta tag" do
      expect(html).to include('<meta property="og:description" content="Description for social media sharing">')
    end

    it "generates og:type meta tag" do
      expect(html).to include('<meta property="og:type" content="article">')
    end

    it "generates og:url meta tag" do
      expect(html).to include('<meta property="og:url" content="https://example.com/article">')
    end

    it "generates og:image meta tag" do
      expect(html).to include('<meta property="og:image" content="https://example.com/og-image.jpg">')
    end

    it "generates og:site_name meta tag" do
      expect(html).to include('<meta property="og:site_name" content="My Awesome Site">')
    end

    it "generates og:locale meta tag" do
      expect(html).to include('<meta property="og:locale" content="en_US">')
    end

    it "generates og:locale:alternate meta tags" do
      expect(html).to include('<meta property="og:locale:alternate" content="it_IT">')
      expect(html).to include('<meta property="og:locale:alternate" content="fr_FR">')
    end

    it "joins all tags with newlines" do
      lines = html.split("\n")
      expect(lines.length).to be >= 8
    end

    it "does not include tags for missing values" do
      minimal = { title: "Title", type: "website", image: "img.jpg", url: "https://example.com" }
      gen = described_class.new(minimal)
      minimal_html = gen.generate

      expect(minimal_html).not_to include("og:site_name")
      expect(minimal_html).not_to include("og:locale")
    end
  end

  describe "image configuration" do
    context "with simple image URL" do
      it "generates og:image tag" do
        gen = described_class.new({ image: "https://example.com/simple.jpg" })
        html = gen.generate
        expect(html).to include('<meta property="og:image" content="https://example.com/simple.jpg">')
      end
    end

    context "with image hash configuration" do
      let(:image_config) do
        {
          image: {
            url: "https://example.com/detailed.jpg",
            width: 1200,
            height: 630,
            alt: "Image description"
          }
        }
      end

      let(:gen) { described_class.new(image_config) }
      let(:html) { gen.generate }

      it "generates og:image tag" do
        expect(html).to include('<meta property="og:image" content="https://example.com/detailed.jpg">')
      end

      it "generates og:image:width tag" do
        expect(html).to include('<meta property="og:image:width" content="1200">')
      end

      it "generates og:image:height tag" do
        expect(html).to include('<meta property="og:image:height" content="630">')
      end

      it "generates og:image:alt tag" do
        expect(html).to include('<meta property="og:image:alt" content="Image description">')
      end
    end
  end

  describe "article properties" do
    let(:article_config) do
      {
        title: "Article Title",
        type: "article",
        url: "https://example.com",
        image: "https://example.com/img.jpg",
        article: {
          author: "John Doe",
          published_time: "2024-01-01T00:00:00Z",
          modified_time: "2024-01-02T00:00:00Z",
          expiration_time: "2024-12-31T23:59:59Z",
          section: "Technology",
          tag: ["Ruby", "SEO", "Rails"]
        }
      }
    end

    let(:gen) { described_class.new(article_config) }
    let(:html) { gen.generate }

    it "generates article:author tag" do
      expect(html).to include('<meta property="article:author" content="John Doe">')
    end

    it "generates article:published_time tag" do
      expect(html).to include('<meta property="article:published_time" content="2024-01-01T00:00:00Z">')
    end

    it "generates article:modified_time tag" do
      expect(html).to include('<meta property="article:modified_time" content="2024-01-02T00:00:00Z">')
    end

    it "generates article:expiration_time tag" do
      expect(html).to include('<meta property="article:expiration_time" content="2024-12-31T23:59:59Z">')
    end

    it "generates article:section tag" do
      expect(html).to include('<meta property="article:section" content="Technology">')
    end

    it "generates multiple article:tag tags" do
      expect(html).to include('<meta property="article:tag" content="Ruby">')
      expect(html).to include('<meta property="article:tag" content="SEO">')
      expect(html).to include('<meta property="article:tag" content="Rails">')
    end
  end

  describe "video properties" do
    context "with simple video URL" do
      it "generates og:video tag" do
        gen = described_class.new({ video: "https://example.com/video.mp4" })
        html = gen.generate
        expect(html).to include('<meta property="og:video" content="https://example.com/video.mp4">')
      end
    end

    context "with video hash configuration" do
      let(:video_config) do
        {
          video: {
            url: "https://example.com/video.mp4",
            width: 1920,
            height: 1080,
            type: "video/mp4"
          }
        }
      end

      let(:gen) { described_class.new(video_config) }
      let(:html) { gen.generate }

      it "generates og:video tag" do
        expect(html).to include('<meta property="og:video" content="https://example.com/video.mp4">')
      end

      it "generates og:video:width tag" do
        expect(html).to include('<meta property="og:video:width" content="1920">')
      end

      it "generates og:video:height tag" do
        expect(html).to include('<meta property="og:video:height" content="1080">')
      end

      it "generates og:video:type tag" do
        expect(html).to include('<meta property="og:video:type" content="video/mp4">')
      end
    end
  end

  describe "audio properties" do
    it "generates og:audio tag" do
      gen = described_class.new({ audio: "https://example.com/audio.mp3" })
      html = gen.generate
      expect(html).to include('<meta property="og:audio" content="https://example.com/audio.mp3">')
    end
  end

  describe "HTML escaping" do
    it "escapes special characters in content" do
      gen = described_class.new({
        title: 'Title with "quotes" & <tags>',
        type: "website",
        url: "https://example.com",
        image: "https://example.com/img.jpg"
      })
      html = gen.generate
      expect(html).to include("&quot;")
      expect(html).to include("&lt;")
      expect(html).to include("&gt;")
      expect(html).to include("&amp;")
    end
  end

  describe "integration with DSL" do
    it "works with OpenGraph DSL output" do
      og = BetterSeo::DSL::OpenGraph.new
      og.title("DSL OG Title")
      og.type("article")
      og.url("https://example.com/dsl")
      og.image("https://example.com/dsl.jpg")
      og.site_name("DSL Site")

      gen = described_class.new(og.build)
      html = gen.generate

      expect(html).to include("DSL OG Title")
      expect(html).to include("article")
      expect(html).to include("https://example.com/dsl")
      expect(html).to include("DSL Site")
    end
  end
end
