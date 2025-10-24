# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::StructuredData::Base do
  describe "#initialize" do
    it "creates instance with type" do
      base = described_class.new("Thing")
      expect(base.type).to eq("Thing")
    end

    it "initializes with empty properties" do
      base = described_class.new("Thing")
      expect(base.properties).to eq({})
    end

    it "accepts initial properties" do
      base = described_class.new("Thing", name: "Test", url: "https://example.com")
      expect(base.properties[:name]).to eq("Test")
      expect(base.properties[:url]).to eq("https://example.com")
    end
  end

  describe "#set" do
    it "sets a property value" do
      base = described_class.new("Thing")
      base.set(:name, "Test Name")
      expect(base.properties[:name]).to eq("Test Name")
    end

    it "overwrites existing property" do
      base = described_class.new("Thing", name: "Old")
      base.set(:name, "New")
      expect(base.properties[:name]).to eq("New")
    end

    it "returns self for chaining" do
      base = described_class.new("Thing")
      result = base.set(:name, "Test")
      expect(result).to eq(base)
    end

    it "allows chaining multiple set calls" do
      base = described_class.new("Thing")
      base.set(:name, "Test").set(:url, "https://example.com").set(:description, "Desc")

      expect(base.properties[:name]).to eq("Test")
      expect(base.properties[:url]).to eq("https://example.com")
      expect(base.properties[:description]).to eq("Desc")
    end

    it "ignores nil values" do
      base = described_class.new("Thing")
      base.set(:name, nil)
      expect(base.properties).not_to have_key(:name)
    end

    it "allows false values" do
      base = described_class.new("Thing")
      base.set(:available, false)
      expect(base.properties[:available]).to be false
    end
  end

  describe "#get" do
    it "retrieves property value" do
      base = described_class.new("Thing", name: "Test")
      expect(base.get(:name)).to eq("Test")
    end

    it "returns nil for missing property" do
      base = described_class.new("Thing")
      expect(base.get(:name)).to be_nil
    end
  end

  describe "#to_h" do
    it "generates hash with @context and @type" do
      base = described_class.new("Thing")
      hash = base.to_h

      expect(hash["@context"]).to eq("https://schema.org")
      expect(hash["@type"]).to eq("Thing")
    end

    it "includes all properties" do
      base = described_class.new("Thing", name: "Test", url: "https://example.com")
      hash = base.to_h

      expect(hash["name"]).to eq("Test")
      expect(hash["url"]).to eq("https://example.com")
    end

    it "converts symbol keys to strings" do
      base = described_class.new("Thing", name: "Test")
      hash = base.to_h

      expect(hash.keys).to all(be_a(String))
    end

    it "excludes nil values" do
      base = described_class.new("Thing")
      base.set(:name, "Test")
      hash = base.to_h

      expect(hash.keys).not_to include("description")
    end

    it "handles nested structured data" do
      author = described_class.new("Person", name: "John Doe")
      article = described_class.new("Article", name: "Test Article")
      article.set(:author, author)

      hash = article.to_h
      expect(hash["author"]).to be_a(Hash)
      expect(hash["author"]["@type"]).to eq("Person")
      expect(hash["author"]["name"]).to eq("John Doe")
    end

    it "handles arrays of structured data" do
      person1 = described_class.new("Person", name: "John")
      person2 = described_class.new("Person", name: "Jane")
      org = described_class.new("Organization")
      org.set(:members, [person1, person2])

      hash = org.to_h
      expect(hash["members"]).to be_a(Array)
      expect(hash["members"].size).to eq(2)
      expect(hash["members"][0]["name"]).to eq("John")
      expect(hash["members"][1]["name"]).to eq("Jane")
    end
  end

  describe "#to_json" do
    it "generates JSON string" do
      base = described_class.new("Thing", name: "Test")
      json = base.to_json

      expect(json).to be_a(String)
      parsed = JSON.parse(json)
      expect(parsed["@type"]).to eq("Thing")
      expect(parsed["name"]).to eq("Test")
    end

    it "pretty prints JSON" do
      base = described_class.new("Thing", name: "Test")
      json = base.to_json

      expect(json).to include("\n")
      expect(json).to match(/\s{2}"@type"/)
    end

    it "handles nested data correctly" do
      author = described_class.new("Person", name: "John Doe")
      article = described_class.new("Article", name: "Test")
      article.set(:author, author)

      json = article.to_json
      parsed = JSON.parse(json)

      expect(parsed["author"]["@type"]).to eq("Person")
      expect(parsed["author"]["name"]).to eq("John Doe")
    end
  end

  describe "#to_script_tag" do
    it "generates HTML script tag" do
      base = described_class.new("Thing", name: "Test")
      tag = base.to_script_tag

      expect(tag).to include('<script type="application/ld+json">')
      expect(tag).to include("</script>")
      expect(tag).to include('"@type": "Thing"')
      expect(tag).to include('"name": "Test"')
    end

    it "includes proper JSON-LD structure" do
      base = described_class.new("Thing", name: "Test")
      tag = base.to_script_tag

      # Extract JSON from script tag
      json_match = tag.match(/<script[^>]*>(.*?)<\/script>/m)
      json = json_match[1].strip
      parsed = JSON.parse(json)

      expect(parsed["@context"]).to eq("https://schema.org")
      expect(parsed["@type"]).to eq("Thing")
    end
  end

  describe "#valid?" do
    it "returns true when @type is present" do
      base = described_class.new("Thing")
      expect(base).to be_valid
    end

    it "returns false when @type is nil" do
      base = described_class.new(nil)
      expect(base).not_to be_valid
    end

    it "returns false when @type is empty" do
      base = described_class.new("")
      expect(base).not_to be_valid
    end
  end

  describe "#validate!" do
    it "does not raise error for valid data" do
      base = described_class.new("Thing")
      expect { base.validate! }.not_to raise_error
    end

    it "raises error when @type is missing" do
      base = described_class.new(nil)
      expect {
        base.validate!
      }.to raise_error(BetterSeo::ValidationError, /@type is required/)
    end

    it "raises error when @type is empty" do
      base = described_class.new("")
      expect {
        base.validate!
      }.to raise_error(BetterSeo::ValidationError, /@type is required/)
    end

    it "returns true when valid" do
      base = described_class.new("Thing")
      expect(base.validate!).to be true
    end
  end

  describe "equality" do
    it "equals another instance with same type and properties" do
      base1 = described_class.new("Thing", name: "Test")
      base2 = described_class.new("Thing", name: "Test")

      expect(base1.to_h).to eq(base2.to_h)
    end

    it "differs when properties differ" do
      base1 = described_class.new("Thing", name: "Test1")
      base2 = described_class.new("Thing", name: "Test2")

      expect(base1.to_h).not_to eq(base2.to_h)
    end
  end
end
