# frozen_string_literal: true

module BetterSeo
  module StructuredData
    class Organization < Base
      def initialize(**properties)
        super("Organization", **properties)
      end

      def name(value)
        set(:name, value)
      end

      def url(value)
        set(:url, value)
      end

      def logo(value)
        set(:logo, value)
      end

      def description(value)
        set(:description, value)
      end

      def email(value)
        set(:email, value)
      end

      def telephone(value)
        set(:telephone, value)
      end

      def address(value)
        if value.is_a?(Hash)
          postal_address = {
            "@type" => "PostalAddress",
            "streetAddress" => value[:street],
            "addressLocality" => value[:city],
            "addressRegion" => value[:region],
            "postalCode" => value[:postal_code],
            "addressCountry" => value[:country]
          }.compact
          set(:address, postal_address)
        else
          set(:address, value)
        end
      end

      def same_as(value)
        set(:sameAs, value)
      end

      def founding_date(value)
        set(:foundingDate, value)
      end

      def founder(value)
        set(:founder, value)
      end

      def founders(value)
        set(:founder, value)
      end
    end
  end
end
