# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::StructuredData::Person do
  describe "#initialize" do
    it "creates Person with correct @type" do
      person = described_class.new
      expect(person.type).to eq("Person")
    end

    it "accepts initial properties" do
      person = described_class.new(
        name: "John Doe",
        email: "john@example.com"
      )

      expect(person.get(:name)).to eq("John Doe")
      expect(person.get(:email)).to eq("john@example.com")
    end
  end

  describe "fluent setters" do
    it "sets name" do
      person = described_class.new
      person.name("John Doe")
      expect(person.get(:name)).to eq("John Doe")
    end

    it "sets given_name" do
      person = described_class.new
      person.given_name("John")
      expect(person.get(:givenName)).to eq("John")
    end

    it "sets family_name" do
      person = described_class.new
      person.family_name("Doe")
      expect(person.get(:familyName)).to eq("Doe")
    end

    it "sets email" do
      person = described_class.new
      person.email("john@example.com")
      expect(person.get(:email)).to eq("john@example.com")
    end

    it "sets url" do
      person = described_class.new
      person.url("https://johndoe.com")
      expect(person.get(:url)).to eq("https://johndoe.com")
    end

    it "sets image" do
      person = described_class.new
      person.image("https://example.com/john.jpg")
      expect(person.get(:image)).to eq("https://example.com/john.jpg")
    end

    it "sets job_title" do
      person = described_class.new
      person.job_title("Senior Developer")
      expect(person.get(:jobTitle)).to eq("Senior Developer")
    end

    it "sets works_for as Organization" do
      org = BetterSeo::StructuredData::Base.new("Organization", name: "Acme Corp")
      person = described_class.new
      person.works_for(org)
      expect(person.get(:worksFor)).to eq(org)
    end

    it "sets telephone" do
      person = described_class.new
      person.telephone("+1-555-0100")
      expect(person.get(:telephone)).to eq("+1-555-0100")
    end

    it "sets same_as social profiles" do
      person = described_class.new
      person.same_as([
        "https://twitter.com/johndoe",
        "https://linkedin.com/in/johndoe"
      ])

      expect(person.get(:sameAs)).to eq([
        "https://twitter.com/johndoe",
        "https://linkedin.com/in/johndoe"
      ])
    end

    it "allows method chaining" do
      person = described_class.new
      result = person
        .name("John Doe")
        .email("john@example.com")
        .url("https://johndoe.com")

      expect(result).to eq(person)
      expect(person.get(:name)).to eq("John Doe")
      expect(person.get(:email)).to eq("john@example.com")
      expect(person.get(:url)).to eq("https://johndoe.com")
    end
  end

  describe "#to_h" do
    it "generates complete person schema" do
      person = described_class.new
      person.name("John Doe")
      person.email("john@example.com")
      person.url("https://johndoe.com")
      person.image("https://example.com/john.jpg")

      hash = person.to_h

      expect(hash["@context"]).to eq("https://schema.org")
      expect(hash["@type"]).to eq("Person")
      expect(hash["name"]).to eq("John Doe")
      expect(hash["email"]).to eq("john@example.com")
      expect(hash["url"]).to eq("https://johndoe.com")
      expect(hash["image"]).to eq("https://example.com/john.jpg")
    end

    it "includes nested Organization for worksFor" do
      org = BetterSeo::StructuredData::Base.new(
        "Organization",
        name: "Acme Corp",
        url: "https://acme.com"
      )
      person = described_class.new
      person.name("John Doe")
      person.works_for(org)

      hash = person.to_h
      expect(hash["worksFor"]).to be_a(Hash)
      expect(hash["worksFor"]["@type"]).to eq("Organization")
      expect(hash["worksFor"]["name"]).to eq("Acme Corp")
    end

    it "includes social profiles" do
      person = described_class.new
      person.name("John Doe")
      person.same_as([
        "https://twitter.com/johndoe",
        "https://github.com/johndoe"
      ])

      hash = person.to_h
      expect(hash["sameAs"]).to eq([
        "https://twitter.com/johndoe",
        "https://github.com/johndoe"
      ])
    end
  end

  describe "#to_script_tag" do
    it "generates valid JSON-LD script tag" do
      person = described_class.new
      person.name("John Doe")
      person.email("john@example.com")
      person.url("https://johndoe.com")

      tag = person.to_script_tag

      expect(tag).to include('<script type="application/ld+json">')
      expect(tag).to include('"@type": "Person"')
      expect(tag).to include('"name": "John Doe"')
      expect(tag).to include('</script>')
    end
  end

  describe "complete example" do
    it "generates comprehensive person markup" do
      org = BetterSeo::StructuredData::Base.new(
        "Organization",
        name: "Tech Innovations Inc",
        url: "https://techinnovations.com"
      )

      person = described_class.new
      person.name("Dr. Jane Smith")
      person.given_name("Jane")
      person.family_name("Smith")
      person.email("jane.smith@techinnovations.com")
      person.url("https://janesmith.dev")
      person.image("https://janesmith.dev/profile.jpg")
      person.job_title("Chief Technology Officer")
      person.works_for(org)
      person.telephone("+1-555-0199")
      person.same_as([
        "https://twitter.com/janesmith",
        "https://linkedin.com/in/janesmith",
        "https://github.com/janesmith"
      ])

      hash = person.to_h

      expect(hash["@type"]).to eq("Person")
      expect(hash["name"]).to eq("Dr. Jane Smith")
      expect(hash["givenName"]).to eq("Jane")
      expect(hash["familyName"]).to eq("Smith")
      expect(hash["email"]).to eq("jane.smith@techinnovations.com")
      expect(hash["url"]).to eq("https://janesmith.dev")
      expect(hash["image"]).to eq("https://janesmith.dev/profile.jpg")
      expect(hash["jobTitle"]).to eq("Chief Technology Officer")
      expect(hash["worksFor"]["@type"]).to eq("Organization")
      expect(hash["worksFor"]["name"]).to eq("Tech Innovations Inc")
      expect(hash["telephone"]).to eq("+1-555-0199")
      expect(hash["sameAs"].size).to eq(3)
    end
  end
end
