# frozen_string_literal: true

require "rails/railtie"

module BetterSeo
  module Rails
    class Railtie < ::Rails::Railtie
      initializer "better_seo.controller_helpers" do
        ActiveSupport.on_load(:action_controller) do
          include BetterSeo::Rails::Helpers::ControllerHelpers
        end
      end

      initializer "better_seo.view_helpers" do
        ActiveSupport.on_load(:action_view) do
          include BetterSeo::Rails::Helpers::SeoHelper
          include BetterSeo::Rails::Helpers::StructuredDataHelper
        end
      end
    end
  end
end
