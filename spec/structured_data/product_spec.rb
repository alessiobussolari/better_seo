# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::StructuredData::Product do
  describe "#initialize" do
    it "creates Product with correct @type" do
      product = described_class.new
      expect(product.type).to eq("Product")
    end

    it "accepts initial properties" do
      product = described_class.new(
        name: "iPhone 15",
        description: "Latest smartphone"
      )

      expect(product.get(:name)).to eq("iPhone 15")
      expect(product.get(:description)).to eq("Latest smartphone")
    end
  end

  describe "fluent setters" do
    it "sets name" do
      product = described_class.new
      product.name("iPhone 15")
      expect(product.get(:name)).to eq("iPhone 15")
    end

    it "sets description" do
      product = described_class.new
      product.description("Latest smartphone with advanced features")
      expect(product.get(:description)).to eq("Latest smartphone with advanced features")
    end

    it "sets image as string" do
      product = described_class.new
      product.image("https://example.com/iphone.jpg")
      expect(product.get(:image)).to eq("https://example.com/iphone.jpg")
    end

    it "sets image as array" do
      product = described_class.new
      product.image([
                      "https://example.com/iphone-1.jpg",
                      "https://example.com/iphone-2.jpg"
                    ])
      expect(product.get(:image)).to eq([
                                          "https://example.com/iphone-1.jpg",
                                          "https://example.com/iphone-2.jpg"
                                        ])
    end

    it "sets brand as string" do
      product = described_class.new
      product.brand("Apple")
      expect(product.get(:brand)).to eq("Apple")
    end

    it "sets brand as Organization" do
      org = BetterSeo::StructuredData::Base.new("Organization", name: "Apple Inc")
      product = described_class.new
      product.brand(org)
      expect(product.get(:brand)).to eq(org)
    end

    it "sets sku" do
      product = described_class.new
      product.sku("IPHONE15-128GB-BLACK")
      expect(product.get(:sku)).to eq("IPHONE15-128GB-BLACK")
    end

    it "sets gtin" do
      product = described_class.new
      product.gtin("0123456789012")
      expect(product.get(:gtin)).to eq("0123456789012")
    end

    it "sets mpn" do
      product = described_class.new
      product.mpn("MQ123LL/A")
      expect(product.get(:mpn)).to eq("MQ123LL/A")
    end

    it "sets offers with hash" do
      product = described_class.new
      product.offers(
        price: 999.99,
        price_currency: "USD",
        availability: "InStock",
        url: "https://example.com/buy"
      )

      offer = product.get(:offers)
      expect(offer).to be_a(Hash)
      expect(offer["@type"]).to eq("Offer")
      expect(offer["price"]).to eq(999.99)
      expect(offer["priceCurrency"]).to eq("USD")
      expect(offer["availability"]).to eq("https://schema.org/InStock")
      expect(offer["url"]).to eq("https://example.com/buy")
    end

    it "sets offers with multiple offers array" do
      product = described_class.new
      product.offers([
                       { price: 999.99, price_currency: "USD", availability: "InStock" },
                       { price: 899.99, price_currency: "USD", availability: "PreOrder" }
                     ])

      offers = product.get(:offers)
      expect(offers).to be_a(Array)
      expect(offers.size).to eq(2)
      expect(offers[0]["price"]).to eq(999.99)
      expect(offers[1]["price"]).to eq(899.99)
    end

    it "sets aggregate_rating" do
      product = described_class.new
      product.aggregate_rating(
        rating_value: 4.5,
        review_count: 250,
        best_rating: 5,
        worst_rating: 1
      )

      rating = product.get(:aggregateRating)
      expect(rating).to be_a(Hash)
      expect(rating["@type"]).to eq("AggregateRating")
      expect(rating["ratingValue"]).to eq(4.5)
      expect(rating["reviewCount"]).to eq(250)
      expect(rating["bestRating"]).to eq(5)
      expect(rating["worstRating"]).to eq(1)
    end

    it "sets review" do
      product = described_class.new
      product.review(
        author: "John Doe",
        date_published: "2024-01-15",
        review_body: "Great product!",
        rating_value: 5
      )

      review = product.get(:review)
      expect(review).to be_a(Hash)
      expect(review["@type"]).to eq("Review")
      expect(review["author"]["@type"]).to eq("Person")
      expect(review["author"]["name"]).to eq("John Doe")
      expect(review["datePublished"]).to eq("2024-01-15")
      expect(review["reviewBody"]).to eq("Great product!")
      expect(review["reviewRating"]["@type"]).to eq("Rating")
      expect(review["reviewRating"]["ratingValue"]).to eq(5)
    end

    it "sets reviews array" do
      product = described_class.new
      product.reviews([
                        { author: "John", rating_value: 5, review_body: "Great!" },
                        { author: "Jane", rating_value: 4, review_body: "Good" }
                      ])

      reviews = product.get(:review)
      expect(reviews).to be_a(Array)
      expect(reviews.size).to eq(2)
      expect(reviews[0]["author"]["name"]).to eq("John")
      expect(reviews[1]["author"]["name"]).to eq("Jane")
    end

    it "allows method chaining" do
      product = described_class.new
      result = product
               .name("iPhone 15")
               .brand("Apple")
               .sku("IPHONE15-BLACK")

      expect(result).to eq(product)
      expect(product.get(:name)).to eq("iPhone 15")
      expect(product.get(:brand)).to eq("Apple")
      expect(product.get(:sku)).to eq("IPHONE15-BLACK")
    end
  end

  describe "#to_h" do
    it "generates complete product schema" do
      product = described_class.new
      product.name("iPhone 15")
      product.description("Latest smartphone")
      product.image("https://example.com/iphone.jpg")
      product.brand("Apple")
      product.sku("IPHONE15-128GB")
      product.offers(
        price: 999.99,
        price_currency: "USD",
        availability: "InStock"
      )

      hash = product.to_h

      expect(hash["@context"]).to eq("https://schema.org")
      expect(hash["@type"]).to eq("Product")
      expect(hash["name"]).to eq("iPhone 15")
      expect(hash["description"]).to eq("Latest smartphone")
      expect(hash["image"]).to eq("https://example.com/iphone.jpg")
      expect(hash["brand"]).to eq("Apple")
      expect(hash["sku"]).to eq("IPHONE15-128GB")
      expect(hash["offers"]["@type"]).to eq("Offer")
      expect(hash["offers"]["price"]).to eq(999.99)
    end

    it "includes aggregate rating" do
      product = described_class.new
      product.name("iPhone 15")
      product.aggregate_rating(
        rating_value: 4.5,
        review_count: 250
      )

      hash = product.to_h
      expect(hash["aggregateRating"]["@type"]).to eq("AggregateRating")
      expect(hash["aggregateRating"]["ratingValue"]).to eq(4.5)
      expect(hash["aggregateRating"]["reviewCount"]).to eq(250)
    end

    it "includes reviews" do
      product = described_class.new
      product.name("iPhone 15")
      product.review(
        author: "John Doe",
        rating_value: 5,
        review_body: "Excellent!"
      )

      hash = product.to_h
      expect(hash["review"]["@type"]).to eq("Review")
      expect(hash["review"]["author"]["name"]).to eq("John Doe")
    end
  end

  describe "#to_script_tag" do
    it "generates valid JSON-LD script tag" do
      product = described_class.new
      product.name("iPhone 15")
      product.brand("Apple")
      product.offers(price: 999.99, price_currency: "USD", availability: "InStock")

      tag = product.to_script_tag

      expect(tag).to include('<script type="application/ld+json">')
      expect(tag).to include('"@type": "Product"')
      expect(tag).to include('"name": "iPhone 15"')
      expect(tag).to include("</script>")
    end
  end

  describe "complete example" do
    it "generates comprehensive product markup" do
      product = described_class.new
      product.name("Premium Wireless Headphones")
      product.description("High-quality wireless headphones with noise cancellation")
      product.image([
                      "https://example.com/headphones-1.jpg",
                      "https://example.com/headphones-2.jpg",
                      "https://example.com/headphones-3.jpg"
                    ])
      product.brand("AudioTech")
      product.sku("HEADPHONES-WL-NC-2024")
      product.gtin("1234567890123")
      product.mpn("AT-WL-NC-001")
      product.offers(
        price: 299.99,
        price_currency: "USD",
        availability: "InStock",
        url: "https://example.com/products/wireless-headphones"
      )
      product.aggregate_rating(
        rating_value: 4.7,
        review_count: 342,
        best_rating: 5,
        worst_rating: 1
      )
      product.review(
        author: "Sarah Johnson",
        date_published: "2024-01-20",
        review_body: "Amazing sound quality and comfort!",
        rating_value: 5
      )

      hash = product.to_h

      expect(hash["@type"]).to eq("Product")
      expect(hash["name"]).to eq("Premium Wireless Headphones")
      expect(hash["description"]).to eq("High-quality wireless headphones with noise cancellation")
      expect(hash["image"]).to be_a(Array)
      expect(hash["image"].size).to eq(3)
      expect(hash["brand"]).to eq("AudioTech")
      expect(hash["sku"]).to eq("HEADPHONES-WL-NC-2024")
      expect(hash["gtin"]).to eq("1234567890123")
      expect(hash["mpn"]).to eq("AT-WL-NC-001")
      expect(hash["offers"]["@type"]).to eq("Offer")
      expect(hash["offers"]["price"]).to eq(299.99)
      expect(hash["offers"]["priceCurrency"]).to eq("USD")
      expect(hash["offers"]["availability"]).to eq("https://schema.org/InStock")
      expect(hash["aggregateRating"]["ratingValue"]).to eq(4.7)
      expect(hash["aggregateRating"]["reviewCount"]).to eq(342)
      expect(hash["review"]["author"]["name"]).to eq("Sarah Johnson")
      expect(hash["review"]["reviewRating"]["ratingValue"]).to eq(5)
    end
  end
end
