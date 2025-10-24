# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::StructuredData::LocalBusiness do
  describe "initialization" do
    it "creates instance with @type LocalBusiness" do
      business = described_class.new
      expect(business.to_h["@type"]).to eq("LocalBusiness")
    end

    it "accepts hash initialization" do
      business = described_class.new(
        name: "Joe's Pizza",
        telephone: "+1-555-0100"
      )

      expect(business.to_h["name"]).to eq("Joe's Pizza")
      expect(business.to_h["telephone"]).to eq("+1-555-0100")
    end
  end

  describe "basic properties" do
    let(:business) { described_class.new }

    it "sets name" do
      business.name("Joe's Pizza")
      expect(business.to_h["name"]).to eq("Joe's Pizza")
    end

    it "sets description" do
      business.description("Best pizza in town")
      expect(business.to_h["description"]).to eq("Best pizza in town")
    end

    it "sets url" do
      business.url("https://joespizza.com")
      expect(business.to_h["url"]).to eq("https://joespizza.com")
    end

    it "sets telephone" do
      business.telephone("+1-555-0100")
      expect(business.to_h["telephone"]).to eq("+1-555-0100")
    end

    it "sets email" do
      business.email("info@joespizza.com")
      expect(business.to_h["email"]).to eq("info@joespizza.com")
    end

    it "sets image as string" do
      business.image("https://example.com/image.jpg")
      expect(business.to_h["image"]).to eq("https://example.com/image.jpg")
    end

    it "sets image as array" do
      business.image(["https://example.com/1.jpg", "https://example.com/2.jpg"])
      expect(business.to_h["image"]).to eq(["https://example.com/1.jpg", "https://example.com/2.jpg"])
    end

    it "sets price range" do
      business.price_range("$$")
      expect(business.to_h["priceRange"]).to eq("$$")
    end
  end

  describe "address handling" do
    let(:business) { described_class.new }

    it "sets address from hash" do
      business.address(
        street: "123 Main St",
        city: "New York",
        region: "NY",
        postal_code: "10001",
        country: "US"
      )

      address = business.to_h["address"]
      expect(address["@type"]).to eq("PostalAddress")
      expect(address["streetAddress"]).to eq("123 Main St")
      expect(address["addressLocality"]).to eq("New York")
      expect(address["addressRegion"]).to eq("NY")
      expect(address["postalCode"]).to eq("10001")
      expect(address["addressCountry"]).to eq("US")
    end

    it "handles partial address" do
      business.address(
        street: "456 Oak Ave",
        city: "Boston"
      )

      address = business.to_h["address"]
      expect(address["streetAddress"]).to eq("456 Oak Ave")
      expect(address["addressLocality"]).to eq("Boston")
      expect(address["addressRegion"]).to be_nil
    end
  end

  describe "geo coordinates" do
    let(:business) { described_class.new }

    it "sets geo coordinates" do
      business.geo(latitude: 40.7128, longitude: -74.0060)

      geo = business.to_h["geo"]
      expect(geo["@type"]).to eq("GeoCoordinates")
      expect(geo["latitude"]).to eq(40.7128)
      expect(geo["longitude"]).to eq(-74.0060)
    end

    it "requires both latitude and longitude" do
      business.geo(latitude: 40.7128, longitude: -74.0060)
      geo = business.to_h["geo"]

      expect(geo["latitude"]).to eq(40.7128)
      expect(geo["longitude"]).to eq(-74.0060)
    end
  end

  describe "opening hours" do
    let(:business) { described_class.new }

    it "sets opening hours as array of strings" do
      hours = [
        "Monday-Friday 09:00-17:00",
        "Saturday 10:00-14:00"
      ]

      business.opening_hours(hours)
      expect(business.to_h["openingHours"]).to eq(hours)
    end

    it "sets opening hours as single string" do
      business.opening_hours("Monday-Sunday 00:00-23:59")
      expect(business.to_h["openingHours"]).to eq("Monday-Sunday 00:00-23:59")
    end

    it "sets opening hours specification with structured data" do
      spec = {
        "@type" => "OpeningHoursSpecification",
        "dayOfWeek" => %w[Monday Tuesday Wednesday Thursday Friday],
        "opens" => "09:00",
        "closes" => "17:00"
      }

      business.opening_hours_specification([spec])
      expect(business.to_h["openingHoursSpecification"]).to eq([spec])
    end
  end

  describe "aggregate rating" do
    let(:business) { described_class.new }

    it "sets aggregate rating" do
      business.aggregate_rating(
        rating_value: 4.5,
        review_count: 250,
        best_rating: 5,
        worst_rating: 1
      )

      rating = business.to_h["aggregateRating"]
      expect(rating["@type"]).to eq("AggregateRating")
      expect(rating["ratingValue"]).to eq(4.5)
      expect(rating["reviewCount"]).to eq(250)
      expect(rating["bestRating"]).to eq(5)
      expect(rating["worstRating"]).to eq(1)
    end

    it "sets aggregate rating with default best/worst" do
      business.aggregate_rating(rating_value: 4.2, review_count: 100)

      rating = business.to_h["aggregateRating"]
      expect(rating["ratingValue"]).to eq(4.2)
      expect(rating["reviewCount"]).to eq(100)
      expect(rating["bestRating"]).to eq(5)
      expect(rating["worstRating"]).to eq(1)
    end
  end

  describe "serves cuisine" do
    let(:business) { described_class.new }

    it "sets serves cuisine as string" do
      business.serves_cuisine("Italian")
      expect(business.to_h["servesCuisine"]).to eq("Italian")
    end

    it "sets serves cuisine as array" do
      business.serves_cuisine(%w[Italian Pizza Pasta])
      expect(business.to_h["servesCuisine"]).to eq(%w[Italian Pizza Pasta])
    end
  end

  describe "method chaining" do
    it "supports fluent interface" do
      business = described_class.new
                                .name("Joe's Pizza")
                                .telephone("+1-555-0100")
                                .price_range("$$")

      expect(business.to_h["name"]).to eq("Joe's Pizza")
      expect(business.to_h["telephone"]).to eq("+1-555-0100")
      expect(business.to_h["priceRange"]).to eq("$$")
    end
  end

  describe "JSON-LD generation" do
    it "generates valid JSON-LD" do
      business = described_class.new
      business.name("Joe's Pizza")
      business.telephone("+1-555-0100")
      business.address(
        street: "123 Main St",
        city: "New York",
        region: "NY",
        postal_code: "10001"
      )
      business.geo(latitude: 40.7128, longitude: -74.0060)

      json = JSON.parse(business.to_json)

      expect(json["@context"]).to eq("https://schema.org")
      expect(json["@type"]).to eq("LocalBusiness")
      expect(json["name"]).to eq("Joe's Pizza")
      expect(json["address"]["@type"]).to eq("PostalAddress")
      expect(json["geo"]["@type"]).to eq("GeoCoordinates")
    end

    it "generates script tag" do
      business = described_class.new(name: "Joe's Pizza")
      script_tag = business.to_script_tag

      expect(script_tag).to include('<script type="application/ld+json">')
      expect(script_tag).to include('"@type": "LocalBusiness"')
      expect(script_tag).to include('"name": "Joe\'s Pizza"')
      expect(script_tag).to include("</script>")
    end
  end

  describe "complete example" do
    it "creates complete local business with all features" do
      business = described_class.new
      business.name("Joe's Authentic Italian Pizza")
      business.description("Family-owned pizzeria serving authentic Italian pizza since 1985")
      business.url("https://joespizza.com")
      business.telephone("+1-555-0100")
      business.email("info@joespizza.com")
      business.image([
                       "https://joespizza.com/images/storefront.jpg",
                       "https://joespizza.com/images/pizza.jpg"
                     ])
      business.price_range("$$")
      business.serves_cuisine(%w[Italian Pizza])
      business.address(
        street: "123 Main Street",
        city: "New York",
        region: "NY",
        postal_code: "10001",
        country: "US"
      )
      business.geo(latitude: 40.7128, longitude: -74.0060)
      business.opening_hours([
                               "Monday-Thursday 11:00-22:00",
                               "Friday-Saturday 11:00-23:00",
                               "Sunday 12:00-21:00"
                             ])
      business.aggregate_rating(rating_value: 4.7, review_count: 523)

      hash = business.to_h

      expect(hash["@type"]).to eq("LocalBusiness")
      expect(hash["name"]).to eq("Joe's Authentic Italian Pizza")
      expect(hash["priceRange"]).to eq("$$")
      expect(hash["servesCuisine"]).to eq(%w[Italian Pizza])
      expect(hash["address"]["@type"]).to eq("PostalAddress")
      expect(hash["geo"]["@type"]).to eq("GeoCoordinates")
      expect(hash["aggregateRating"]["@type"]).to eq("AggregateRating")
      expect(hash["openingHours"]).to be_an(Array)
      expect(hash["openingHours"].size).to eq(3)
    end
  end
end
