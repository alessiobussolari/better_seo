# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::DSL::MetaTags do
  subject(:meta_tags) { described_class.new }

  describe "#initialize" do
    it "inherits from Base" do
      expect(meta_tags).to be_a(BetterSeo::DSL::Base)
    end

    it "starts with empty config" do
      expect(meta_tags.config).to eq({})
    end
  end

  describe "#title" do
    context "when setting value" do
      it "sets title with argument" do
        result = meta_tags.title("My Page Title")
        expect(meta_tags.get(:title)).to eq("My Page Title")
        expect(result).to eq(meta_tags) # Returns self for chaining
      end
    end

    context "when getting value" do
      it "returns title without argument" do
        meta_tags.set(:title, "Stored Title")
        expect(meta_tags.title).to eq("Stored Title")
      end

      it "returns nil if not set" do
        expect(meta_tags.title).to be_nil
      end
    end
  end

  describe "#description" do
    context "when setting value" do
      it "sets description with argument" do
        result = meta_tags.description("My page description")
        expect(meta_tags.get(:description)).to eq("My page description")
        expect(result).to eq(meta_tags)
      end
    end

    context "when getting value" do
      it "returns description without argument" do
        meta_tags.set(:description, "Stored description")
        expect(meta_tags.description).to eq("Stored description")
      end

      it "returns nil if not set" do
        expect(meta_tags.description).to be_nil
      end
    end
  end

  describe "#keywords" do
    context "when setting values" do
      it "sets keywords from multiple arguments" do
        result = meta_tags.keywords("seo", "ruby", "rails")
        expect(meta_tags.get(:keywords)).to eq(%w[seo ruby rails])
        expect(result).to eq(meta_tags)
      end

      it "sets keywords from array" do
        meta_tags.keywords(%w[web development])
        expect(meta_tags.get(:keywords)).to eq(%w[web development])
      end

      it "flattens nested arrays" do
        meta_tags.keywords("seo", %w[ruby rails], "web")
        expect(meta_tags.get(:keywords)).to eq(%w[seo ruby rails web])
      end
    end

    context "when getting values" do
      it "returns keywords without arguments" do
        meta_tags.set(:keywords, %w[test keywords])
        expect(meta_tags.keywords).to eq(%w[test keywords])
      end

      it "returns nil if not set" do
        expect(meta_tags.keywords).to be_nil
      end
    end
  end

  describe "#author" do
    it "sets and gets author" do
      meta_tags.author("John Doe")
      expect(meta_tags.author).to eq("John Doe")
    end
  end

  describe "#canonical" do
    it "sets and gets canonical URL" do
      meta_tags.canonical("https://example.com/page")
      expect(meta_tags.canonical).to eq("https://example.com/page")
    end
  end

  describe "#robots" do
    it "sets default robots directives (index: true, follow: true)" do
      meta_tags.robots
      expect(meta_tags.get(:robots)).to eq({ index: true, follow: true })
    end

    it "sets custom index and follow values" do
      meta_tags.robots(index: false, follow: true)
      expect(meta_tags.get(:robots)).to eq({ index: false, follow: true })
    end

    it "accepts additional options" do
      meta_tags.robots(index: true, follow: true, noarchive: true, noimageindex: true)
      expect(meta_tags.get(:robots)).to eq({
                                             index: true,
                                             follow: true,
                                             noarchive: true,
                                             noimageindex: true
                                           })
    end

    it "returns self for chaining" do
      expect(meta_tags.robots).to eq(meta_tags)
    end
  end

  describe "#viewport" do
    it "sets default viewport value" do
      meta_tags.viewport
      expect(meta_tags.get(:viewport)).to eq("width=device-width, initial-scale=1.0")
    end

    it "sets custom viewport value" do
      meta_tags.viewport("width=1024")
      expect(meta_tags.get(:viewport)).to eq("width=1024")
    end

    it "returns self for chaining" do
      expect(meta_tags.viewport).to eq(meta_tags)
    end
  end

  describe "#charset" do
    it "sets default charset to UTF-8" do
      meta_tags.charset
      expect(meta_tags.get(:charset)).to eq("UTF-8")
    end

    it "sets custom charset value" do
      meta_tags.charset("ISO-8859-1")
      expect(meta_tags.get(:charset)).to eq("ISO-8859-1")
    end

    it "returns self for chaining" do
      expect(meta_tags.charset).to eq(meta_tags)
    end
  end

  describe "#build" do
    it "returns complete configuration" do
      meta_tags.evaluate do
        title "Test Title"
        description "Test Description"
        keywords "ruby", "rails"
        author "John Doe"
        canonical "https://example.com"
        robots index: true, follow: false
        viewport
        charset
      end

      result = meta_tags.build

      expect(result[:title]).to eq("Test Title")
      expect(result[:description]).to eq("Test Description")
      expect(result[:keywords]).to eq(%w[ruby rails])
      expect(result[:author]).to eq("John Doe")
      expect(result[:canonical]).to eq("https://example.com")
      expect(result[:robots]).to eq({ index: true, follow: false })
      expect(result[:viewport]).to eq("width=device-width, initial-scale=1.0")
      expect(result[:charset]).to eq("UTF-8")
    end
  end

  describe "#validate!" do
    context "with valid data" do
      it "does not raise error for valid title length" do
        meta_tags.title("A" * 60)
        expect { meta_tags.send(:validate!) }.not_to raise_error
      end

      it "does not raise error for valid description length" do
        meta_tags.description("A" * 160)
        expect { meta_tags.send(:validate!) }.not_to raise_error
      end
    end

    context "with invalid data" do
      it "raises error when title is too long" do
        meta_tags.title("A" * 80)
        expect do
          meta_tags.send(:validate!)
        end.to raise_error(BetterSeo::ValidationError, /Title too long/)
      end

      it "raises error when description is too long" do
        meta_tags.description("A" * 200)
        expect do
          meta_tags.send(:validate!)
        end.to raise_error(BetterSeo::ValidationError, /Description too long/)
      end

      it "raises error with both title and description too long" do
        meta_tags.title("A" * 80)
        meta_tags.description("A" * 200)
        expect do
          meta_tags.send(:validate!)
        end.to raise_error(BetterSeo::ValidationError, /Title too long.*Description too long/)
      end
    end
  end

  describe "method chaining" do
    it "supports fluent interface" do
      result = meta_tags
               .title("Chained Title")
               .description("Chained Description")
               .keywords("ruby", "rails")
               .author("Jane Doe")
               .canonical("https://example.com/chain")
               .robots(index: true, follow: true)
               .viewport
               .charset

      expect(result).to eq(meta_tags)
      expect(meta_tags.title).to eq("Chained Title")
      expect(meta_tags.description).to eq("Chained Description")
      expect(meta_tags.keywords).to eq(%w[ruby rails])
      expect(meta_tags.author).to eq("Jane Doe")
      expect(meta_tags.canonical).to eq("https://example.com/chain")
    end
  end
end
