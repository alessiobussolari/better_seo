# frozen_string_literal: true

module BetterSeo
  module StructuredData
    class Generator
      class << self
        def generate_script_tags(structured_data_array)
          return "" if structured_data_array.empty?

          structured_data_array.map(&:to_script_tag).join("\n\n")
        end

        def organization(**properties)
          org = Organization.new(**properties)
          yield(org) if block_given?
          org
        end

        def article(**properties)
          article = Article.new(**properties)
          yield(article) if block_given?
          article
        end

        def person(**properties)
          person = Person.new(**properties)
          yield(person) if block_given?
          person
        end

        def product(**properties)
          product = Product.new(**properties)
          yield(product) if block_given?
          product
        end

        def breadcrumb_list(**properties)
          breadcrumb = BreadcrumbList.new(**properties)
          yield(breadcrumb) if block_given?
          breadcrumb
        end

        def local_business(**properties)
          business = LocalBusiness.new(**properties)
          yield(business) if block_given?
          business
        end

        def event(**properties)
          event = Event.new(**properties)
          yield(event) if block_given?
          event
        end

        def faq_page(**properties)
          faq = FAQPage.new(**properties)
          yield(faq) if block_given?
          faq
        end

        def how_to(**properties)
          how_to = HowTo.new(**properties)
          yield(how_to) if block_given?
          how_to
        end

        def recipe(**properties)
          recipe = Recipe.new(**properties)
          yield(recipe) if block_given?
          recipe
        end
      end
    end
  end
end
