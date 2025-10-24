# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::Generators::AmpGenerator do
  describe "#initialize" do
    it "creates generator with default settings" do
      generator = described_class.new
      expect(generator.canonical_url).to be_nil
      expect(generator.title).to be_nil
    end

    it "creates generator with initial attributes" do
      generator = described_class.new(
        canonical_url: "https://example.com/article",
        title: "Test Article"
      )
      expect(generator.canonical_url).to eq("https://example.com/article")
      expect(generator.title).to eq("Test Article")
    end
  end

  describe "attribute setters" do
    let(:generator) { described_class.new }

    it "sets canonical URL" do
      generator.canonical_url = "https://example.com/page"
      expect(generator.canonical_url).to eq("https://example.com/page")
    end

    it "sets title" do
      generator.title = "My Page Title"
      expect(generator.title).to eq("My Page Title")
    end

    it "sets description" do
      generator.description = "Page description"
      expect(generator.description).to eq("Page description")
    end

    it "sets image" do
      generator.image = "https://example.com/image.jpg"
      expect(generator.image).to eq("https://example.com/image.jpg")
    end

    it "sets structured data" do
      data = { "@type" => "Article", "headline" => "Test" }
      generator.structured_data = data
      expect(generator.structured_data).to eq(data)
    end
  end

  describe "#to_boilerplate" do
    it "generates AMP boilerplate CSS" do
      generator = described_class.new
      boilerplate = generator.to_boilerplate

      expect(boilerplate).to include("<style amp-boilerplate>")
      expect(boilerplate).to include("-amp-start 8s steps(1,end)")
      expect(boilerplate).to include("</style>")
    end

    it "generates noscript boilerplate" do
      generator = described_class.new
      boilerplate = generator.to_boilerplate

      expect(boilerplate).to include("<noscript>")
      expect(boilerplate).to include("<style amp-boilerplate>")
      expect(boilerplate).to include("</noscript>")
    end
  end

  describe "#to_meta_tags" do
    it "generates canonical link when URL provided" do
      generator = described_class.new(canonical_url: "https://example.com/article")
      meta = generator.to_meta_tags

      expect(meta).to include('<link rel="canonical" href="https://example.com/article">')
    end

    it "does not generate canonical when not provided" do
      generator = described_class.new
      meta = generator.to_meta_tags

      expect(meta).to eq("")
    end

    it "generates title meta tag" do
      generator = described_class.new(title: "My Article")
      meta = generator.to_meta_tags

      expect(meta).to include('<meta property="og:title" content="My Article">')
    end

    it "generates description meta tag" do
      generator = described_class.new
      generator.description = "Article description"
      meta = generator.to_meta_tags

      expect(meta).to include('<meta name="description" content="Article description">')
      expect(meta).to include('<meta property="og:description" content="Article description">')
    end

    it "generates image meta tag" do
      generator = described_class.new
      generator.image = "https://example.com/image.jpg"
      meta = generator.to_meta_tags

      expect(meta).to include('<meta property="og:image" content="https://example.com/image.jpg">')
    end

    it "escapes HTML entities in meta tags" do
      generator = described_class.new(title: "Article & Guide")
      meta = generator.to_meta_tags

      expect(meta).to include('content="Article &amp; Guide"')
    end
  end

  describe "#to_structured_data" do
    it "generates script tag with structured data" do
      generator = described_class.new
      data = {
        "@context" => "https://schema.org",
        "@type" => "Article",
        "headline" => "Test Article"
      }
      generator.structured_data = data

      script = generator.to_structured_data

      expect(script).to include('<script type="application/ld+json">')
      expect(script).to include('"@type":"Article"')
      expect(script).to include('"headline":"Test Article"')
      expect(script).to include("</script>")
    end

    it "returns empty string when no structured data" do
      generator = described_class.new
      script = generator.to_structured_data

      expect(script).to eq("")
    end
  end

  describe "#to_amp_script_tag" do
    it "generates AMP runtime script tag" do
      generator = described_class.new
      script = generator.to_amp_script_tag

      expect(script).to include('<script async src="https://cdn.ampproject.org/v0.js"></script>')
    end
  end

  describe "#to_custom_css" do
    it "wraps custom CSS in amp-custom style tag" do
      generator = described_class.new
      css = "body { font-family: Arial; }"
      result = generator.to_custom_css(css)

      expect(result).to include("<style amp-custom>")
      expect(result).to include("body { font-family: Arial; }")
      expect(result).to include("</style>")
    end

    it "returns empty string when no CSS provided" do
      generator = described_class.new
      result = generator.to_custom_css(nil)

      expect(result).to eq("")
    end

    it "returns empty string when empty CSS provided" do
      generator = described_class.new
      result = generator.to_custom_css("")

      expect(result).to eq("")
    end
  end

  describe "Rails integration" do
    it "generates complete AMP head section" do
      generator = described_class.new(
        canonical_url: "https://example.com/article",
        title: "My Article",
        description: "Article description",
        image: "https://example.com/image.jpg"
      )

      meta = generator.to_meta_tags
      boilerplate = generator.to_boilerplate
      amp_script = generator.to_amp_script_tag

      expect(meta).to include("canonical")
      expect(meta).to include("My Article")
      expect(boilerplate).to include("amp-boilerplate")
      expect(amp_script).to include("cdn.ampproject.org")
    end
  end
end
