# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::DSL::Base do
  subject(:builder) { described_class.new }

  describe "#initialize" do
    it "initializes with empty config" do
      expect(builder.config).to eq({})
    end
  end

  describe "#set and #get" do
    it "sets and gets values" do
      builder.set(:title, "My Title")
      expect(builder.get(:title)).to eq("My Title")
    end

    it "returns self for chaining" do
      result = builder.set(:title, "Title")
      expect(result).to eq(builder)
    end
  end

  describe "method_missing for setters" do
    it "sets values using method calls without arguments block" do
      builder.title "My Title"
      expect(builder.get(:title)).to eq("My Title")
    end

    it "sets values using assignment operator" do
      builder.title = "My Title"
      expect(builder.get(:title)).to eq("My Title")
    end

    it "gets values using method calls without arguments" do
      builder.set(:title, "My Title")
      expect(builder.title).to eq("My Title")
    end

    it "returns self for chaining with method calls" do
      result = builder.title("Title")
      expect(result).to eq(builder)
    end
  end

  describe "nested blocks" do
    it "supports nested configuration blocks" do
      builder.evaluate do
        title "Main Title"

        open_graph do
          title "OG Title"
          image "https://example.com/image.jpg"
        end
      end

      expect(builder.get(:title)).to eq("Main Title")
      expect(builder.get(:open_graph)).to eq({
        title: "OG Title",
        image: "https://example.com/image.jpg"
      })
    end

    it "supports deeply nested blocks" do
      builder.evaluate do
        meta do
          title "Meta Title"

          og do
            title "OG Title"
          end
        end
      end

      expect(builder.get(:meta)).to be_a(Hash)
      expect(builder.get(:meta)[:title]).to eq("Meta Title")
      expect(builder.get(:meta)[:og]).to eq({ title: "OG Title" })
    end
  end

  describe "#evaluate" do
    it "evaluates block in context of builder" do
      builder.evaluate do
        title "Test Title"
        description "Test Description"
      end

      expect(builder.title).to eq("Test Title")
      expect(builder.description).to eq("Test Description")
    end

    it "returns self" do
      result = builder.evaluate { title "Test" }
      expect(result).to eq(builder)
    end

    it "does nothing if no block given" do
      expect { builder.evaluate }.not_to raise_error
    end
  end

  describe "#build" do
    before do
      builder.title "Title"
      builder.description "Description"
    end

    it "returns configuration hash" do
      result = builder.build

      expect(result).to eq({
        title: "Title",
        description: "Description"
      })
    end

    it "returns a copy of config" do
      result = builder.build
      result[:title] = "Modified"

      expect(builder.title).to eq("Title")  # Original unchanged
    end

    it "calls validate! before returning" do
      expect(builder).to receive(:validate!).and_call_original
      builder.build
    end
  end

  describe "#to_h" do
    it "returns configuration as hash" do
      builder.title "Title"

      result = builder.to_h

      expect(result).to eq({ title: "Title" })
    end

    it "returns a copy" do
      builder.title "Title"
      result = builder.to_h
      result[:title] = "Modified"

      expect(builder.title).to eq("Title")
    end
  end

  describe "#merge!" do
    before do
      builder.title "Original Title"
      builder.description "Original Description"
    end

    it "merges hash configuration" do
      builder.merge!(description: "New Description", keywords: ["seo", "ruby"])

      expect(builder.title).to eq("Original Title")  # Preserved
      expect(builder.description).to eq("New Description")  # Updated
      expect(builder.keywords).to eq(["seo", "ruby"])  # Added
    end

    it "merges another builder" do
      other = described_class.new
      other.title "Other Title"
      other.author "Other Author"

      builder.merge!(other)

      expect(builder.title).to eq("Other Title")
      expect(builder.description).to eq("Original Description")  # Preserved
      expect(builder.author).to eq("Other Author")
    end

    it "returns self for chaining" do
      result = builder.merge!(title: "New")
      expect(result).to eq(builder)
    end

    it "raises error when merging invalid object" do
      expect {
        builder.merge!("invalid")
      }.to raise_error(BetterSeo::DSLError, /Cannot merge/)
    end
  end

  describe "#validate!" do
    it "returns true by default" do
      expect(builder.send(:validate!)).to be true
    end

    it "can be overridden in subclasses" do
      custom_class = Class.new(described_class) do
        def validate!
          raise BetterSeo::ValidationError, "Custom validation failed"
        end
      end

      custom_builder = custom_class.new

      expect {
        custom_builder.build
      }.to raise_error(BetterSeo::ValidationError, /Custom validation/)
    end
  end

  describe "#respond_to_missing?" do
    it "returns true for any method" do
      expect(builder.respond_to?(:any_method)).to be true
      expect(builder.respond_to?(:another_method=)).to be true
    end
  end
end
