# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::StructuredData::Organization do
  describe "#initialize" do
    it "creates Organization with correct @type" do
      org = described_class.new
      expect(org.type).to eq("Organization")
    end

    it "accepts initial properties" do
      org = described_class.new(
        name: "Acme Corp",
        url: "https://acme.com"
      )

      expect(org.get(:name)).to eq("Acme Corp")
      expect(org.get(:url)).to eq("https://acme.com")
    end
  end

  describe "fluent setters" do
    it "sets name" do
      org = described_class.new
      org.name("Acme Corp")
      expect(org.get(:name)).to eq("Acme Corp")
    end

    it "sets url" do
      org = described_class.new
      org.url("https://acme.com")
      expect(org.get(:url)).to eq("https://acme.com")
    end

    it "sets logo" do
      org = described_class.new
      org.logo("https://acme.com/logo.png")
      expect(org.get(:logo)).to eq("https://acme.com/logo.png")
    end

    it "sets description" do
      org = described_class.new
      org.description("A leading company")
      expect(org.get(:description)).to eq("A leading company")
    end

    it "sets email" do
      org = described_class.new
      org.email("info@acme.com")
      expect(org.get(:email)).to eq("info@acme.com")
    end

    it "sets telephone" do
      org = described_class.new
      org.telephone("+1-555-0100")
      expect(org.get(:telephone)).to eq("+1-555-0100")
    end

    it "sets address as hash" do
      org = described_class.new
      org.address(
        street: "123 Main St",
        city: "New York",
        region: "NY",
        postal_code: "10001",
        country: "US"
      )

      address = org.get(:address)
      expect(address).to be_a(Hash)
      expect(address["@type"]).to eq("PostalAddress")
      expect(address["streetAddress"]).to eq("123 Main St")
      expect(address["addressLocality"]).to eq("New York")
    end

    it "sets sameAs social profiles" do
      org = described_class.new
      org.same_as([
                    "https://twitter.com/acme",
                    "https://facebook.com/acme",
                    "https://linkedin.com/company/acme"
                  ])

      expect(org.get(:sameAs)).to eq([
                                       "https://twitter.com/acme",
                                       "https://facebook.com/acme",
                                       "https://linkedin.com/company/acme"
                                     ])
    end

    it "sets founding date" do
      org = described_class.new
      org.founding_date("2020-01-15")
      expect(org.get(:foundingDate)).to eq("2020-01-15")
    end

    it "sets founder as Person" do
      founder = BetterSeo::StructuredData::Base.new("Person", name: "John Doe")
      org = described_class.new
      org.founder(founder)

      expect(org.get(:founder)).to eq(founder)
    end

    it "sets founders as array" do
      founder1 = BetterSeo::StructuredData::Base.new("Person", name: "John")
      founder2 = BetterSeo::StructuredData::Base.new("Person", name: "Jane")
      org = described_class.new
      org.founders([founder1, founder2])

      expect(org.get(:founder)).to eq([founder1, founder2])
    end

    it "allows method chaining" do
      org = described_class.new
      result = org
               .name("Acme Corp")
               .url("https://acme.com")
               .email("info@acme.com")

      expect(result).to eq(org)
      expect(org.get(:name)).to eq("Acme Corp")
      expect(org.get(:url)).to eq("https://acme.com")
      expect(org.get(:email)).to eq("info@acme.com")
    end
  end

  describe "#to_h" do
    it "generates complete organization schema" do
      org = described_class.new
      org.name("Acme Corp")
      org.url("https://acme.com")
      org.logo("https://acme.com/logo.png")
      org.description("Leading technology company")

      hash = org.to_h

      expect(hash["@context"]).to eq("https://schema.org")
      expect(hash["@type"]).to eq("Organization")
      expect(hash["name"]).to eq("Acme Corp")
      expect(hash["url"]).to eq("https://acme.com")
      expect(hash["logo"]).to eq("https://acme.com/logo.png")
      expect(hash["description"]).to eq("Leading technology company")
    end

    it "includes address in correct format" do
      org = described_class.new
      org.name("Acme Corp")
      org.address(
        street: "123 Main St",
        city: "New York",
        region: "NY",
        postal_code: "10001",
        country: "US"
      )

      hash = org.to_h
      address = hash["address"]

      expect(address["@type"]).to eq("PostalAddress")
      expect(address["streetAddress"]).to eq("123 Main St")
      expect(address["addressLocality"]).to eq("New York")
      expect(address["addressRegion"]).to eq("NY")
      expect(address["postalCode"]).to eq("10001")
      expect(address["addressCountry"]).to eq("US")
    end

    it "includes social profiles" do
      org = described_class.new
      org.name("Acme Corp")
      org.same_as([
                    "https://twitter.com/acme",
                    "https://facebook.com/acme"
                  ])

      hash = org.to_h
      expect(hash["sameAs"]).to eq([
                                     "https://twitter.com/acme",
                                     "https://facebook.com/acme"
                                   ])
    end

    it "includes nested Person for founder" do
      founder = BetterSeo::StructuredData::Base.new(
        "Person",
        name: "John Doe",
        email: "john@example.com"
      )
      org = described_class.new
      org.name("Acme Corp")
      org.founder(founder)

      hash = org.to_h
      expect(hash["founder"]).to be_a(Hash)
      expect(hash["founder"]["@type"]).to eq("Person")
      expect(hash["founder"]["name"]).to eq("John Doe")
    end
  end

  describe "#to_script_tag" do
    it "generates valid JSON-LD script tag" do
      org = described_class.new
      org.name("Acme Corp")
      org.url("https://acme.com")
      org.logo("https://acme.com/logo.png")

      tag = org.to_script_tag

      expect(tag).to include('<script type="application/ld+json">')
      expect(tag).to include('"@type": "Organization"')
      expect(tag).to include('"name": "Acme Corp"')
      expect(tag).to include("</script>")
    end
  end

  describe "validation" do
    it "is valid with name" do
      org = described_class.new(name: "Acme Corp")
      expect(org).to be_valid
    end

    it "validates successfully with required fields" do
      org = described_class.new(name: "Acme Corp")
      expect { org.validate! }.not_to raise_error
    end
  end

  describe "complete example" do
    it "generates comprehensive organization markup" do
      org = described_class.new
      org.name("Acme Corporation")
      org.url("https://www.acme.com")
      org.logo("https://www.acme.com/images/logo.png")
      org.description("Leading provider of innovative solutions")
      org.email("contact@acme.com")
      org.telephone("+1-555-0100")
      org.address(
        street: "123 Technology Drive",
        city: "San Francisco",
        region: "CA",
        postal_code: "94105",
        country: "US"
      )
      org.same_as([
                    "https://www.facebook.com/acmecorp",
                    "https://www.twitter.com/acmecorp",
                    "https://www.linkedin.com/company/acmecorp"
                  ])
      org.founding_date("2015-03-20")

      hash = org.to_h

      expect(hash["@type"]).to eq("Organization")
      expect(hash["name"]).to eq("Acme Corporation")
      expect(hash["url"]).to eq("https://www.acme.com")
      expect(hash["logo"]).to eq("https://www.acme.com/images/logo.png")
      expect(hash["description"]).to eq("Leading provider of innovative solutions")
      expect(hash["email"]).to eq("contact@acme.com")
      expect(hash["telephone"]).to eq("+1-555-0100")
      expect(hash["address"]["@type"]).to eq("PostalAddress")
      expect(hash["sameAs"].size).to eq(3)
      expect(hash["foundingDate"]).to eq("2015-03-20")
    end
  end
end
