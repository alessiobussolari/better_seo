# frozen_string_literal: true

module BetterSeo
  module Rails
    module Helpers
      module StructuredDataHelper
        TYPE_MAPPING = {
          organization: BetterSeo::StructuredData::Organization,
          article: BetterSeo::StructuredData::Article,
          person: BetterSeo::StructuredData::Person,
          product: BetterSeo::StructuredData::Product,
          breadcrumb_list: BetterSeo::StructuredData::BreadcrumbList,
          local_business: BetterSeo::StructuredData::LocalBusiness,
          event: BetterSeo::StructuredData::Event,
          faq_page: BetterSeo::StructuredData::FAQPage,
          how_to: BetterSeo::StructuredData::HowTo,
          recipe: BetterSeo::StructuredData::Recipe
        }.freeze

        def structured_data_tag(type_or_object, **properties, &block)
          sd_object = if type_or_object.is_a?(Symbol)
                        create_structured_data(type_or_object, properties, &block)
                      else
                        type_or_object
                      end

          raw(sd_object.to_script_tag)
        end

        def structured_data_tags(objects = nil)
          array = block_given? ? yield : objects
          return "" if array.nil? || array.empty?

          tags = array.map(&:to_script_tag).join("\n\n")
          raw(tags)
        end

        def organization_sd(**properties, &block)
          structured_data_tag(:organization, **properties, &block)
        end

        def article_sd(**properties, &block)
          structured_data_tag(:article, **properties, &block)
        end

        def person_sd(**properties, &block)
          structured_data_tag(:person, **properties, &block)
        end

        def product_sd(**properties, &block)
          structured_data_tag(:product, **properties, &block)
        end

        def breadcrumb_list_sd(items: nil, &block)
          if block_given?
            structured_data_tag(:breadcrumb_list, &block)
          elsif items
            structured_data_tag(:breadcrumb_list) do |breadcrumb|
              breadcrumb.add_items(items)
            end
          else
            structured_data_tag(:breadcrumb_list)
          end
        end

        def local_business_sd(**properties, &block)
          structured_data_tag(:local_business, **properties, &block)
        end

        def event_sd(**properties, &block)
          structured_data_tag(:event, **properties, &block)
        end

        def faq_page_sd(questions: nil, &block)
          if block_given?
            structured_data_tag(:faq_page, &block)
          elsif questions
            structured_data_tag(:faq_page) do |faq|
              faq.add_questions(questions)
            end
          else
            structured_data_tag(:faq_page)
          end
        end

        def how_to_sd(steps: nil, &block)
          if block_given?
            structured_data_tag(:how_to, &block)
          elsif steps
            structured_data_tag(:how_to) do |how_to|
              how_to.add_steps(steps)
            end
          else
            structured_data_tag(:how_to)
          end
        end

        def recipe_sd(ingredients: nil, instructions: nil, &block)
          if block_given?
            structured_data_tag(:recipe, &block)
          else
            structured_data_tag(:recipe) do |recipe|
              recipe.add_ingredients(ingredients) if ingredients
              recipe.add_instructions(instructions) if instructions
              yield(recipe) if block_given?
            end
          end
        end

        private

        def create_structured_data(type, properties)
          klass = TYPE_MAPPING[type]
          raise ArgumentError, "Unknown structured data type: #{type}" unless klass

          sd_object = klass.new(**properties)
          yield(sd_object) if block_given?
          sd_object
        end
      end
    end
  end
end
