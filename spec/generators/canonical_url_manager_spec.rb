# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::Generators::CanonicalUrlManager do
  describe "#initialize" do
    it "creates manager without URL" do
      manager = described_class.new
      expect(manager.url).to be_nil
    end

    it "creates manager with URL" do
      manager = described_class.new("https://example.com/page")
      expect(manager.url).to eq("https://example.com/page")
    end
  end

  describe "#url=" do
    it "sets the canonical URL" do
      manager = described_class.new
      manager.url = "https://example.com/article"
      expect(manager.url).to eq("https://example.com/article")
    end

    it "normalizes URL by removing trailing slash" do
      manager = described_class.new
      manager.url = "https://example.com/page/"
      expect(manager.url).to eq("https://example.com/page")
    end

    it "preserves root URL trailing slash" do
      manager = described_class.new
      manager.url = "https://example.com/"
      expect(manager.url).to eq("https://example.com/")
    end

    it "removes query parameters when configured" do
      manager = described_class.new
      manager.remove_query_params = true
      manager.url = "https://example.com/page?utm_source=twitter&ref=123"
      expect(manager.url).to eq("https://example.com/page")
    end

    it "preserves query parameters by default" do
      manager = described_class.new
      manager.url = "https://example.com/page?page=2"
      expect(manager.url).to eq("https://example.com/page?page=2")
    end

    it "removes fragment identifiers" do
      manager = described_class.new
      manager.url = "https://example.com/page#section"
      expect(manager.url).to eq("https://example.com/page")
    end

    it "lowercases the URL when configured" do
      manager = described_class.new
      manager.lowercase = true
      manager.url = "https://Example.com/Page"
      expect(manager.url).to eq("https://example.com/page")
    end

    it "does not lowercase by default" do
      manager = described_class.new
      manager.url = "https://Example.com/Page"
      expect(manager.url).to eq("https://Example.com/Page")
    end

    it "handles nil URL" do
      manager = described_class.new("https://example.com")
      manager.url = nil
      expect(manager.url).to be_nil
    end
  end

  describe "#to_html" do
    it "generates canonical link tag" do
      manager = described_class.new("https://example.com/article")
      html = manager.to_html

      expect(html).to eq('<link rel="canonical" href="https://example.com/article">')
    end

    it "escapes HTML entities in URL" do
      manager = described_class.new("https://example.com/search?q=test&category=books")
      html = manager.to_html

      expect(html).to include('href="https://example.com/search?q=test&amp;category=books"')
    end

    it "returns empty string when URL is nil" do
      manager = described_class.new
      html = manager.to_html

      expect(html).to eq("")
    end
  end

  describe "#to_http_header" do
    it "generates Link HTTP header" do
      manager = described_class.new("https://example.com/article")
      header = manager.to_http_header

      expect(header).to eq('<https://example.com/article>; rel="canonical"')
    end

    it "returns empty string when URL is nil" do
      manager = described_class.new
      header = manager.to_http_header

      expect(header).to eq("")
    end
  end

  describe "#validate!" do
    it "validates valid HTTPS URL" do
      manager = described_class.new("https://example.com/page")
      expect { manager.validate! }.not_to raise_error
    end

    it "validates valid HTTP URL" do
      manager = described_class.new("http://example.com/page")
      expect { manager.validate! }.not_to raise_error
    end

    it "raises error for invalid URL format" do
      manager = described_class.new("not a url")
      expect { manager.validate! }.to raise_error(BetterSeo::ValidationError, /Invalid URL format/)
    end

    it "raises error for relative URL" do
      manager = described_class.new("/page")
      expect { manager.validate! }.to raise_error(BetterSeo::ValidationError, /must be absolute/)
    end

    it "raises error when URL is nil" do
      manager = described_class.new
      expect { manager.validate! }.to raise_error(BetterSeo::ValidationError, /URL is required/)
    end

    it "raises error for empty URL" do
      manager = described_class.new("")
      expect { manager.validate! }.to raise_error(BetterSeo::ValidationError, /URL is required/)
    end
  end

  describe "URL normalization options" do
    it "applies multiple normalization rules" do
      manager = described_class.new
      manager.remove_query_params = true
      manager.lowercase = true
      manager.url = "https://Example.com/Page/?utm_source=google#section"

      expect(manager.url).to eq("https://example.com/page")
    end

    it "normalizes URL on initialization" do
      manager = described_class.new("https://example.com/page/")
      expect(manager.url).to eq("https://example.com/page")
    end
  end

  describe "Rails integration" do
    it "generates canonical tag for Rails views" do
      manager = described_class.new("https://example.com/products/123")
      html = manager.to_html

      expect(html).to include('rel="canonical"')
      expect(html).to include('https://example.com/products/123')
    end

    it "can be used in controller to set response header" do
      manager = described_class.new("https://example.com/article")
      header = manager.to_http_header

      expect(header).to match(/<https:.*>; rel="canonical"/)
    end
  end
end
