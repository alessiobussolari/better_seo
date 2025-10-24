# frozen_string_literal: true

module BetterSeo
  module Rails
    module ModelHelpers
      extend ActiveSupport::Concern

      class_methods do
        # Define SEO attribute mappings
        # @example
        #   seo_attributes(
        #     title: :post_title,
        #     description: :excerpt,
        #     keywords: -> { tags.map(&:name).join(", ") },
        #     image: :featured_image_url
        #   )
        def seo_attributes(mappings = {})
          @_seo_attribute_mappings = mappings

          # Define accessor methods for each SEO attribute
          mappings.each do |seo_attr, source|
            define_method("seo_#{seo_attr}") do
              evaluate_seo_attribute(source)
            end
          end
        end

        def seo_attribute_mappings
          @_seo_attribute_mappings || {}
        end
      end

      # Convert model to SEO hash
      def to_seo_hash
        mappings = self.class.seo_attribute_mappings
        return {} if mappings.empty?

        hash = {}

        mappings.each_key do |seo_attr|
          value = send("seo_#{seo_attr}")
          hash[seo_attr] = value if value
        end

        hash
      end

      private

      def evaluate_seo_attribute(source)
        case source
        when Proc
          instance_exec(&source)
        when Symbol
          send(source) if respond_to?(source)
        else
          source
        end
      end
    end
  end
end
