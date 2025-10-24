# frozen_string_literal: true

require "active_support"
require "active_support/core_ext"

require_relative "better_seo/version"
require_relative "better_seo/errors"
require_relative "better_seo/configuration"
require_relative "better_seo/dsl/base"
require_relative "better_seo/dsl/meta_tags"
require_relative "better_seo/dsl/open_graph"
require_relative "better_seo/dsl/twitter_cards"
require_relative "better_seo/generators/meta_tags_generator"
require_relative "better_seo/generators/open_graph_generator"
require_relative "better_seo/generators/twitter_cards_generator"
require_relative "better_seo/generators/breadcrumbs_generator"
require_relative "better_seo/generators/amp_generator"
require_relative "better_seo/generators/canonical_url_manager"
require_relative "better_seo/generators/robots_txt_generator"
require_relative "better_seo/validators/seo_validator"
require_relative "better_seo/validators/seo_recommendations"
require_relative "better_seo/image/optimizer"
require_relative "better_seo/analytics/google_analytics"
require_relative "better_seo/analytics/google_tag_manager"
require_relative "better_seo/sitemap/url_entry"
require_relative "better_seo/sitemap/builder"
require_relative "better_seo/sitemap/generator"
require_relative "better_seo/sitemap/sitemap_index"
require_relative "better_seo/structured_data/base"
require_relative "better_seo/structured_data/organization"
require_relative "better_seo/structured_data/article"
require_relative "better_seo/structured_data/person"
require_relative "better_seo/structured_data/product"
require_relative "better_seo/structured_data/breadcrumb_list"
require_relative "better_seo/structured_data/local_business"
require_relative "better_seo/structured_data/event"
require_relative "better_seo/structured_data/faq_page"
require_relative "better_seo/structured_data/how_to"
require_relative "better_seo/structured_data/recipe"
require_relative "better_seo/structured_data/generator"
require_relative "better_seo/rails/helpers/seo_helper"
require_relative "better_seo/rails/helpers/structured_data_helper"
require_relative "better_seo/rails/helpers/controller_helpers"
require_relative "better_seo/rails/model_helpers"

module BetterSeo
  class << self
    # Accesso alla configurazione singleton
    def configuration
      @configuration ||= Configuration.new
    end

    # Block-style configuration
    def configure
      yield(configuration) if block_given?
      configuration.validate! if block_given?
      configuration
    end

    # Reset configuration (utile per test)
    def reset_configuration!
      @configuration = Configuration.new
    end

    # Shortcut per check feature enabled
    def enabled?(feature)
      configuration.public_send("#{feature}_enabled?")
    rescue NoMethodError
      false
    end
  end
end
