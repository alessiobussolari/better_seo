# frozen_string_literal: true

module BetterSeo
  module StructuredData
    class Product < Base
      AVAILABILITY_MAPPING = {
        "InStock" => "https://schema.org/InStock",
        "OutOfStock" => "https://schema.org/OutOfStock",
        "PreOrder" => "https://schema.org/PreOrder",
        "Discontinued" => "https://schema.org/Discontinued",
        "LimitedAvailability" => "https://schema.org/LimitedAvailability"
      }.freeze

      def initialize(**properties)
        super("Product", **properties)
      end

      def name(value)
        set(:name, value)
      end

      def description(value)
        set(:description, value)
      end

      def image(value)
        set(:image, value)
      end

      def brand(value)
        set(:brand, value)
      end

      def sku(value)
        set(:sku, value)
      end

      def gtin(value)
        set(:gtin, value)
      end

      def mpn(value)
        set(:mpn, value)
      end

      def offers(value)
        if value.is_a?(Array)
          set(:offers, value.map { |v| build_offer(v) })
        elsif value.is_a?(Hash)
          set(:offers, build_offer(value))
        else
          set(:offers, value)
        end
      end

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

      def review(author:, rating_value:, review_body: nil, date_published: nil)
        review_data = build_review(
          author: author,
          rating_value: rating_value,
          review_body: review_body,
          date_published: date_published
        )
        set(:review, review_data)
      end

      def reviews(reviews_array)
        reviews_data = reviews_array.map do |review_hash|
          build_review(
            author: review_hash[:author],
            rating_value: review_hash[:rating_value],
            review_body: review_hash[:review_body],
            date_published: review_hash[:date_published]
          )
        end
        set(:review, reviews_data)
      end

      private

      def build_offer(offer_hash)
        availability = offer_hash[:availability] || "InStock"
        availability_url = AVAILABILITY_MAPPING[availability] || "https://schema.org/#{availability}"

        offer = {
          "@type" => "Offer",
          "price" => offer_hash[:price],
          "priceCurrency" => offer_hash[:price_currency],
          "availability" => availability_url
        }
        offer["url"] = offer_hash[:url] if offer_hash[:url]
        offer.compact
      end

      def build_review(author:, rating_value:, review_body: nil, date_published: nil)
        review = {
          "@type" => "Review",
          "author" => {
            "@type" => "Person",
            "name" => author
          },
          "reviewRating" => {
            "@type" => "Rating",
            "ratingValue" => rating_value
          }
        }
        review["reviewBody"] = review_body if review_body
        review["datePublished"] = date_published if date_published
        review
      end
    end
  end
end
