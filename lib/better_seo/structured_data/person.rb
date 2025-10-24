# frozen_string_literal: true

module BetterSeo
  module StructuredData
    class Person < Base
      def initialize(**properties)
        super("Person", **properties)
      end

      def name(value)
        set(:name, value)
      end

      def given_name(value)
        set(:givenName, value)
      end

      def family_name(value)
        set(:familyName, value)
      end

      def email(value)
        set(:email, value)
      end

      def url(value)
        set(:url, value)
      end

      def image(value)
        set(:image, value)
      end

      def job_title(value)
        set(:jobTitle, value)
      end

      def works_for(value)
        set(:worksFor, value)
      end

      def telephone(value)
        set(:telephone, value)
      end

      def same_as(value)
        set(:sameAs, value)
      end
    end
  end
end
