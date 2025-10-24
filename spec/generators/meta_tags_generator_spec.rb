# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::Generators::MetaTagsGenerator do
  let(:config) do
    {
      charset: "UTF-8",
      viewport: "width=device-width, initial-scale=1.0",
      title: "Test Page Title",
      description: "This is a test page description for SEO",
      keywords: ["ruby", "seo", "meta tags"],
      author: "John Doe",
      canonical: "https://example.com/test-page",
      robots: { index: true, follow: true, noarchive: true }
    }
  end

  subject(:generator) { described_class.new(config) }

  describe "#initialize" do
    it "accepts configuration hash" do
      expect(generator.instance_variable_get(:@config)).to eq(config)
    end

    it "works with empty config" do
      empty_generator = described_class.new({})
      expect(empty_generator.instance_variable_get(:@config)).to eq({})
    end
  end

  describe "#generate" do
    let(:html) { generator.generate }

    it "returns a string" do
      expect(html).to be_a(String)
    end

    it "generates charset meta tag" do
      expect(html).to include('<meta charset="UTF-8">')
    end

    it "generates viewport meta tag" do
      expect(html).to include('<meta name="viewport" content="width=device-width, initial-scale=1.0">')
    end

    it "generates title tag" do
      expect(html).to include('<title>Test Page Title</title>')
    end

    it "generates description meta tag" do
      expect(html).to include('<meta name="description" content="This is a test page description for SEO">')
    end

    it "generates keywords meta tag" do
      expect(html).to include('<meta name="keywords" content="ruby, seo, meta tags">')
    end

    it "generates author meta tag" do
      expect(html).to include('<meta name="author" content="John Doe">')
    end

    it "generates canonical link tag" do
      expect(html).to include('<link rel="canonical" href="https://example.com/test-page">')
    end

    it "generates robots meta tag with correct directives" do
      expect(html).to include('<meta name="robots" content="index, follow, noarchive">')
    end

    it "joins all tags with newlines" do
      lines = html.split("\n")
      expect(lines.length).to be > 5
    end

    it "does not include tags for missing values" do
      minimal_config = { title: "Only Title" }
      minimal_generator = described_class.new(minimal_config)
      minimal_html = minimal_generator.generate

      expect(minimal_html).to include("<title>")
      expect(minimal_html).not_to include("description")
      expect(minimal_html).not_to include("keywords")
      expect(minimal_html).not_to include("author")
    end
  end

  describe "#charset_tag" do
    it "generates charset meta tag" do
      expect(generator.charset_tag).to eq('<meta charset="UTF-8">')
    end

    it "returns nil when charset not present" do
      gen = described_class.new({})
      expect(gen.charset_tag).to be_nil
    end
  end

  describe "#viewport_tag" do
    it "generates viewport meta tag" do
      expect(generator.viewport_tag).to eq(
        '<meta name="viewport" content="width=device-width, initial-scale=1.0">'
      )
    end

    it "returns nil when viewport not present" do
      gen = described_class.new({})
      expect(gen.viewport_tag).to be_nil
    end
  end

  describe "#title_tag" do
    it "generates title tag" do
      expect(generator.title_tag).to eq('<title>Test Page Title</title>')
    end

    it "returns nil when title not present" do
      gen = described_class.new({})
      expect(gen.title_tag).to be_nil
    end
  end

  describe "#description_tag" do
    it "generates description meta tag" do
      expect(generator.description_tag).to eq(
        '<meta name="description" content="This is a test page description for SEO">'
      )
    end

    it "returns nil when description not present" do
      gen = described_class.new({})
      expect(gen.description_tag).to be_nil
    end
  end

  describe "#keywords_tag" do
    it "generates keywords meta tag from array" do
      expect(generator.keywords_tag).to eq(
        '<meta name="keywords" content="ruby, seo, meta tags">'
      )
    end

    it "handles single keyword" do
      gen = described_class.new({ keywords: ["seo"] })
      expect(gen.keywords_tag).to eq('<meta name="keywords" content="seo">')
    end

    it "returns nil when keywords not present" do
      gen = described_class.new({})
      expect(gen.keywords_tag).to be_nil
    end

    it "handles empty keywords array" do
      gen = described_class.new({ keywords: [] })
      expect(gen.keywords_tag).to be_nil
    end
  end

  describe "#author_tag" do
    it "generates author meta tag" do
      expect(generator.author_tag).to eq('<meta name="author" content="John Doe">')
    end

    it "returns nil when author not present" do
      gen = described_class.new({})
      expect(gen.author_tag).to be_nil
    end
  end

  describe "#canonical_tag" do
    it "generates canonical link tag" do
      expect(generator.canonical_tag).to eq(
        '<link rel="canonical" href="https://example.com/test-page">'
      )
    end

    it "returns nil when canonical not present" do
      gen = described_class.new({})
      expect(gen.canonical_tag).to be_nil
    end
  end

  describe "#robots_tag" do
    it "generates robots meta tag with index and follow" do
      expect(generator.robots_tag).to include("index")
      expect(generator.robots_tag).to include("follow")
      expect(generator.robots_tag).to include("noarchive")
    end

    it "generates noindex when index is false" do
      gen = described_class.new({ robots: { index: false, follow: true } })
      expect(gen.robots_tag).to include("noindex")
      expect(gen.robots_tag).to include("follow")
    end

    it "generates nofollow when follow is false" do
      gen = described_class.new({ robots: { index: true, follow: false } })
      expect(gen.robots_tag).to include("index")
      expect(gen.robots_tag).to include("nofollow")
    end

    it "includes additional robot directives" do
      gen = described_class.new({
        robots: {
          index: true,
          follow: true,
          noarchive: true,
          noimageindex: true,
          nosnippet: true
        }
      })
      tag = gen.robots_tag
      expect(tag).to include("noarchive")
      expect(tag).to include("noimageindex")
      expect(tag).to include("nosnippet")
    end

    it "returns nil when robots not present" do
      gen = described_class.new({})
      expect(gen.robots_tag).to be_nil
    end
  end

  describe "HTML escaping" do
    it "escapes double quotes in content" do
      gen = described_class.new({ title: 'Title with "quotes"' })
      expect(gen.title_tag).to include("&quot;")
      expect(gen.title_tag).not_to include('with "quotes"')
    end

    it "escapes < and > characters" do
      gen = described_class.new({ description: "Test <script>alert('xss')</script>" })
      expect(gen.description_tag).to include("&lt;script&gt;")
      expect(gen.description_tag).not_to include("<script>")
    end

    it "escapes ampersands" do
      gen = described_class.new({ author: "John & Jane Doe" })
      expect(gen.author_tag).to include("John &amp; Jane Doe")
    end

    it "handles multiple special characters" do
      gen = described_class.new({
        title: 'Test "Title" with <tags> & special chars'
      })
      tag = gen.title_tag
      expect(tag).to include("&quot;")
      expect(tag).to include("&lt;")
      expect(tag).to include("&gt;")
      expect(tag).to include("&amp;")
    end
  end

  describe "integration with DSL" do
    it "works with MetaTags DSL output" do
      meta = BetterSeo::DSL::MetaTags.new
      meta.title("DSL Title")
      meta.description("DSL Description")
      meta.keywords("dsl", "test")
      meta.robots(index: true, follow: false)

      gen = described_class.new(meta.build)
      html = gen.generate

      expect(html).to include("<title>DSL Title</title>")
      expect(html).to include("DSL Description")
      expect(html).to include("dsl, test")
      expect(html).to include("nofollow")
    end
  end
end
