# frozen_string_literal: true

require "rails/generators/base"

module BetterSeo
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Creates a BetterSeo initializer file"

      def copy_initializer
        template "better_seo.rb", "config/initializers/better_seo.rb"
      end

      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end
