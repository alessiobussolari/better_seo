# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::StructuredData::Generator do
  describe ".generate_script_tags" do
    it "generates script tags from array of structured data" do
      org = BetterSeo::StructuredData::Organization.new
      org.name("Acme Corp")

      person = BetterSeo::StructuredData::Person.new
      person.name("John Doe")

      tags = described_class.generate_script_tags([org, person])

      expect(tags).to include('<script type="application/ld+json">')
      expect(tags).to include('"@type": "Organization"')
      expect(tags).to include('"@type": "Person"')
      expect(tags.scan(/<script/).size).to eq(2)
    end

    it "generates single script tag from one item" do
      org = BetterSeo::StructuredData::Organization.new(name: "Acme")

      tags = described_class.generate_script_tags([org])

      expect(tags).to include('"@type": "Organization"')
      expect(tags.scan(/<script/).size).to eq(1)
    end

    it "returns empty string for empty array" do
      tags = described_class.generate_script_tags([])
      expect(tags).to eq("")
    end

    it "joins multiple tags with newlines" do
      org = BetterSeo::StructuredData::Organization.new(name: "Acme")
      person = BetterSeo::StructuredData::Person.new(name: "John")

      tags = described_class.generate_script_tags([org, person])
      expect(tags).to include("\n\n")
    end
  end

  describe ".organization" do
    it "creates new Organization instance" do
      org = described_class.organization

      expect(org).to be_a(BetterSeo::StructuredData::Organization)
      expect(org.type).to eq("Organization")
    end

    it "accepts block for configuration" do
      org = described_class.organization do |o|
        o.name("Acme Corp")
        o.url("https://acme.com")
      end

      expect(org.get(:name)).to eq("Acme Corp")
      expect(org.get(:url)).to eq("https://acme.com")
    end

    it "accepts initial properties" do
      org = described_class.organization(name: "Acme", url: "https://acme.com")

      expect(org.get(:name)).to eq("Acme")
      expect(org.get(:url)).to eq("https://acme.com")
    end
  end

  describe ".article" do
    it "creates new Article instance" do
      article = described_class.article

      expect(article).to be_a(BetterSeo::StructuredData::Article)
      expect(article.type).to eq("Article")
    end

    it "accepts block for configuration" do
      article = described_class.article do |a|
        a.headline("Test Article")
        a.author("John Doe")
      end

      expect(article.get(:headline)).to eq("Test Article")
      expect(article.get(:author)).to eq("John Doe")
    end

    it "accepts initial properties" do
      article = described_class.article(headline: "Test", author: "John")

      expect(article.get(:headline)).to eq("Test")
      expect(article.get(:author)).to eq("John")
    end
  end

  describe ".person" do
    it "creates new Person instance" do
      person = described_class.person

      expect(person).to be_a(BetterSeo::StructuredData::Person)
      expect(person.type).to eq("Person")
    end

    it "accepts block for configuration" do
      person = described_class.person do |p|
        p.name("John Doe")
        p.email("john@example.com")
      end

      expect(person.get(:name)).to eq("John Doe")
      expect(person.get(:email)).to eq("john@example.com")
    end

    it "accepts initial properties" do
      person = described_class.person(name: "John", email: "john@example.com")

      expect(person.get(:name)).to eq("John")
      expect(person.get(:email)).to eq("john@example.com")
    end
  end

  describe "integration example" do
    it "generates complete structured data markup" do
      org = described_class.organization do |o|
        o.name("Tech Corp")
        o.url("https://techcorp.com")
      end

      author = described_class.person do |p|
        p.name("Jane Smith")
        p.email("jane@techcorp.com")
      end

      article = described_class.article do |a|
        a.headline("Introduction to Ruby")
        a.author(author)
        a.publisher(org)
        a.date_published("2024-01-15")
      end

      tags = described_class.generate_script_tags([org, author, article])

      expect(tags).to include('"@type": "Organization"')
      expect(tags).to include('"@type": "Person"')
      expect(tags).to include('"@type": "Article"')
      expect(tags).to include('"name": "Tech Corp"')
      expect(tags).to include('"name": "Jane Smith"')
      expect(tags).to include('"headline": "Introduction to Ruby"')
    end
  end
end
