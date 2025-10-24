# frozen_string_literal: true

module BetterSeo
  module StructuredData
    class Generator
      class << self
        def generate_script_tags(structured_data_array)
          return "" if structured_data_array.empty?

          structured_data_array.map(&:to_script_tag).join("\n\n")
        end

        def organization(**properties, &block)
          org = Organization.new(**properties)
          yield(org) if block_given?
          org
        end

        def article(**properties, &block)
          article = Article.new(**properties)
          yield(article) if block_given?
          article
        end

        def person(**properties, &block)
          person = Person.new(**properties)
          yield(person) if block_given?
          person
        end

        def product(**properties, &block)
          product = Product.new(**properties)
          yield(product) if block_given?
          product
        end

        def breadcrumb_list(**properties, &block)
          breadcrumb = BreadcrumbList.new(**properties)
          yield(breadcrumb) if block_given?
          breadcrumb
        end

        def local_business(**properties, &block)
          business = LocalBusiness.new(**properties)
          yield(business) if block_given?
          business
        end

        def event(**properties, &block)
          event = Event.new(**properties)
          yield(event) if block_given?
          event
        end

        def faq_page(**properties, &block)
          faq = FAQPage.new(**properties)
          yield(faq) if block_given?
          faq
        end

        def how_to(**properties, &block)
          how_to = HowTo.new(**properties)
          yield(how_to) if block_given?
          how_to
        end

        def recipe(**properties, &block)
          recipe = Recipe.new(**properties)
          yield(recipe) if block_given?
          recipe
        end
      end
    end
  end
end
