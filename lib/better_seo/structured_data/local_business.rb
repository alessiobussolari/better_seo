# frozen_string_literal: true

module BetterSeo
  module StructuredData
    class LocalBusiness < Base
      def initialize(**properties)
        super("LocalBusiness", **properties)
      end

      # Basic properties
      def name(value)
        set(:name, value)
      end

      def description(value)
        set(:description, value)
      end

      def url(value)
        set(:url, value)
      end

      def telephone(value)
        set(:telephone, value)
      end

      def email(value)
        set(:email, value)
      end

      def image(value)
        set(:image, value)
      end

      def price_range(value)
        set(:priceRange, value)
      end

      # Address with PostalAddress schema
      def address(street: nil, city: nil, region: nil, postal_code: nil, country: nil)
        address_hash = {
          "@type" => "PostalAddress"
        }

        address_hash["streetAddress"] = street if street
        address_hash["addressLocality"] = city if city
        address_hash["addressRegion"] = region if region
        address_hash["postalCode"] = postal_code if postal_code
        address_hash["addressCountry"] = country if country

        set(:address, address_hash)
      end

      # Geographic coordinates
      def geo(latitude:, longitude:)
        geo_hash = {
          "@type" => "GeoCoordinates",
          "latitude" => latitude,
          "longitude" => longitude
        }

        set(:geo, geo_hash)
      end

      # Opening hours - accepts string or array
      def opening_hours(value)
        set(:openingHours, value)
      end

      # Opening hours specification (structured format)
      def opening_hours_specification(value)
        set(:openingHoursSpecification, value)
      end

      # Aggregate rating
      def aggregate_rating(rating_value:, review_count:, best_rating: 5, worst_rating: 1)
        rating = {
          "@type" => "AggregateRating",
          "ratingValue" => rating_value,
          "reviewCount" => review_count,
          "bestRating" => best_rating,
          "worstRating" => worst_rating
        }

        set(:aggregateRating, rating)
      end

      # Serves cuisine (for restaurants)
      def serves_cuisine(value)
        set(:servesCuisine, value)
      end
    end
  end
end
