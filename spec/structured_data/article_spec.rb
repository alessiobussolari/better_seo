# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::StructuredData::Article do
  describe "#initialize" do
    it "creates Article with correct @type" do
      article = described_class.new
      expect(article.type).to eq("Article")
    end

    it "accepts initial properties" do
      article = described_class.new(
        headline: "Test Article",
        author: "John Doe"
      )

      expect(article.get(:headline)).to eq("Test Article")
      expect(article.get(:author)).to eq("John Doe")
    end
  end

  describe "fluent setters" do
    it "sets headline" do
      article = described_class.new
      article.headline("Amazing Article Title")
      expect(article.get(:headline)).to eq("Amazing Article Title")
    end

    it "sets description" do
      article = described_class.new
      article.description("Article description here")
      expect(article.get(:description)).to eq("Article description here")
    end

    it "sets image as string" do
      article = described_class.new
      article.image("https://example.com/image.jpg")
      expect(article.get(:image)).to eq("https://example.com/image.jpg")
    end

    it "sets image as array" do
      article = described_class.new
      article.image([
        "https://example.com/image1.jpg",
        "https://example.com/image2.jpg"
      ])
      expect(article.get(:image)).to eq([
        "https://example.com/image1.jpg",
        "https://example.com/image2.jpg"
      ])
    end

    it "sets author as string" do
      article = described_class.new
      article.author("John Doe")
      expect(article.get(:author)).to eq("John Doe")
    end

    it "sets author as Person object" do
      person = BetterSeo::StructuredData::Base.new("Person", name: "John Doe")
      article = described_class.new
      article.author(person)
      expect(article.get(:author)).to eq(person)
    end

    it "sets publisher as Organization" do
      org = BetterSeo::StructuredData::Base.new(
        "Organization",
        name: "Publisher Inc",
        logo: "https://example.com/logo.png"
      )
      article = described_class.new
      article.publisher(org)
      expect(article.get(:publisher)).to eq(org)
    end

    it "sets date_published" do
      article = described_class.new
      article.date_published("2024-01-15")
      expect(article.get(:datePublished)).to eq("2024-01-15")
    end

    it "sets date_modified" do
      article = described_class.new
      article.date_modified("2024-01-20")
      expect(article.get(:dateModified)).to eq("2024-01-20")
    end

    it "sets url" do
      article = described_class.new
      article.url("https://example.com/article")
      expect(article.get(:url)).to eq("https://example.com/article")
    end

    it "sets word_count" do
      article = described_class.new
      article.word_count(1500)
      expect(article.get(:wordCount)).to eq(1500)
    end

    it "sets keywords as array" do
      article = described_class.new
      article.keywords(["ruby", "rails", "seo"])
      expect(article.get(:keywords)).to eq(["ruby", "rails", "seo"])
    end

    it "sets article_section" do
      article = described_class.new
      article.article_section("Technology")
      expect(article.get(:articleSection)).to eq("Technology")
    end

    it "allows method chaining" do
      article = described_class.new
      result = article
        .headline("Test")
        .author("John Doe")
        .date_published("2024-01-15")

      expect(result).to eq(article)
      expect(article.get(:headline)).to eq("Test")
      expect(article.get(:author)).to eq("John Doe")
      expect(article.get(:datePublished)).to eq("2024-01-15")
    end
  end

  describe "#to_h" do
    it "generates complete article schema" do
      article = described_class.new
      article.headline("Amazing Article")
      article.description("This is an amazing article")
      article.image("https://example.com/image.jpg")
      article.author("John Doe")
      article.date_published("2024-01-15")

      hash = article.to_h

      expect(hash["@context"]).to eq("https://schema.org")
      expect(hash["@type"]).to eq("Article")
      expect(hash["headline"]).to eq("Amazing Article")
      expect(hash["description"]).to eq("This is an amazing article")
      expect(hash["image"]).to eq("https://example.com/image.jpg")
      expect(hash["author"]).to eq("John Doe")
      expect(hash["datePublished"]).to eq("2024-01-15")
    end

    it "includes nested Person for author" do
      person = BetterSeo::StructuredData::Base.new(
        "Person",
        name: "John Doe",
        url: "https://example.com/john"
      )
      article = described_class.new
      article.headline("Test Article")
      article.author(person)

      hash = article.to_h
      expect(hash["author"]).to be_a(Hash)
      expect(hash["author"]["@type"]).to eq("Person")
      expect(hash["author"]["name"]).to eq("John Doe")
    end

    it "includes nested Organization for publisher" do
      org = BetterSeo::StructuredData::Base.new(
        "Organization",
        name: "Publisher Inc",
        logo: "https://example.com/logo.png"
      )
      article = described_class.new
      article.headline("Test")
      article.publisher(org)

      hash = article.to_h
      expect(hash["publisher"]).to be_a(Hash)
      expect(hash["publisher"]["@type"]).to eq("Organization")
      expect(hash["publisher"]["name"]).to eq("Publisher Inc")
    end

    it "includes multiple images" do
      article = described_class.new
      article.headline("Test")
      article.image([
        "https://example.com/img1.jpg",
        "https://example.com/img2.jpg",
        "https://example.com/img3.jpg"
      ])

      hash = article.to_h
      expect(hash["image"]).to be_a(Array)
      expect(hash["image"].size).to eq(3)
    end
  end

  describe "#to_script_tag" do
    it "generates valid JSON-LD script tag" do
      article = described_class.new
      article.headline("Test Article")
      article.author("John Doe")
      article.date_published("2024-01-15")

      tag = article.to_script_tag

      expect(tag).to include('<script type="application/ld+json">')
      expect(tag).to include('"@type": "Article"')
      expect(tag).to include('"headline": "Test Article"')
      expect(tag).to include('</script>')
    end
  end

  describe "complete example" do
    it "generates comprehensive article markup" do
      author = BetterSeo::StructuredData::Base.new(
        "Person",
        name: "Jane Smith",
        url: "https://example.com/authors/jane-smith"
      )

      publisher = BetterSeo::StructuredData::Base.new(
        "Organization",
        name: "Tech Publishing Co",
        logo: "https://example.com/logo.png"
      )

      article = described_class.new
      article.headline("The Future of Ruby on Rails in 2024")
      article.description("An in-depth look at Ruby on Rails trends and innovations")
      article.image([
        "https://example.com/images/rails-future-1.jpg",
        "https://example.com/images/rails-future-2.jpg"
      ])
      article.author(author)
      article.publisher(publisher)
      article.date_published("2024-01-15T09:00:00Z")
      article.date_modified("2024-01-20T14:30:00Z")
      article.url("https://example.com/articles/future-of-rails-2024")
      article.word_count(2500)
      article.keywords(["Ruby on Rails", "Web Development", "2024 Trends"])
      article.article_section("Technology")

      hash = article.to_h

      expect(hash["@type"]).to eq("Article")
      expect(hash["headline"]).to eq("The Future of Ruby on Rails in 2024")
      expect(hash["description"]).to eq("An in-depth look at Ruby on Rails trends and innovations")
      expect(hash["image"]).to be_a(Array)
      expect(hash["image"].size).to eq(2)
      expect(hash["author"]["@type"]).to eq("Person")
      expect(hash["author"]["name"]).to eq("Jane Smith")
      expect(hash["publisher"]["@type"]).to eq("Organization")
      expect(hash["publisher"]["name"]).to eq("Tech Publishing Co")
      expect(hash["datePublished"]).to eq("2024-01-15T09:00:00Z")
      expect(hash["dateModified"]).to eq("2024-01-20T14:30:00Z")
      expect(hash["url"]).to eq("https://example.com/articles/future-of-rails-2024")
      expect(hash["wordCount"]).to eq(2500)
      expect(hash["keywords"]).to eq(["Ruby on Rails", "Web Development", "2024 Trends"])
      expect(hash["articleSection"]).to eq("Technology")
    end
  end
end
