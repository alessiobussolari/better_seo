# Step 05: Rails Integration Completa

**Versione Target**: 0.6.0
**Durata Stimata**: 2 settimane
**Priorità**: 🔴 ALTA
**Dipendenze**: Step 01, 02, 03, 04

---

## Obiettivi

1. ✅ View helpers completi (meta_tags, open_graph, structured_data)
2. ✅ Controller concerns (SeoAware)
3. ✅ Rails generators (install, config, sitemap, robots)
4. ✅ Rails Engine
5. ✅ Routes integration
6. ✅ Middleware (optional)

---

## File da Creare

```
lib/better_seo/rails/helpers/meta_tags_helper.rb
lib/better_seo/rails/helpers/open_graph_helper.rb
lib/better_seo/rails/helpers/structured_data_helper.rb
lib/better_seo/rails/concerns/seo_aware.rb
lib/better_seo/rails/engine.rb
lib/generators/better_seo/install_generator.rb
lib/generators/better_seo/config_generator.rb
lib/generators/better_seo/page_generator.rb (parziale, completato in Step 06)
```

---

## Implementazione: MetaTagsHelper

```ruby
# lib/better_seo/rails/helpers/meta_tags_helper.rb
module BetterSeo
  module Rails
    module Helpers
      module MetaTagsHelper
        def seo_meta_tags(options = {}, &block)
          meta_dsl = BetterSeo::DSL::MetaTags.new

          # Load defaults from configuration
          config = BetterSeo.configuration.meta_tags
          meta_dsl.merge!(config.to_h)

          # Load from controller if set
          if controller.respond_to?(:current_seo_meta) && controller.current_seo_meta
            meta_dsl.merge!(controller.current_seo_meta)
          end

          # Apply block overrides
          meta_dsl.evaluate(&block) if block_given?

          # Apply options hash
          meta_dsl.merge!(options) if options.any?

          # Generate HTML
          generator = BetterSeo::Generators::MetaTagsGenerator.new(meta_dsl.build)
          generator.generate.html_safe
        end

        def render_seo_tags
          tags = []
          tags << seo_meta_tags
          tags << open_graph_tags if BetterSeo.configuration.open_graph_enabled?
          tags << twitter_card_tags if BetterSeo.configuration.twitter_enabled?
          tags << structured_data_tags if BetterSeo.configuration.structured_data_enabled?

          safe_join(tags, "\n")
        end
      end
    end
  end
end
```

---

## Implementazione: SeoAware Concern

```ruby
# lib/better_seo/rails/concerns/seo_aware.rb
module BetterSeo
  module Rails
    module Concerns
      module SeoAware
        extend ActiveSupport::Concern

        included do
          helper_method :current_seo_meta, :current_seo_og, :current_seo_structured_data
        end

        def set_seo(&block)
          @_seo_builder = BetterSeo::DSL::MetaTags.new
          @_seo_builder.evaluate(&block) if block_given?
        end

        def set_seo_from_locale(page_name)
          # Implementato in Step 06
        end

        def current_seo_meta
          @_seo_builder&.to_h || {}
        end

        def current_seo_og
          @_seo_og || {}
        end

        def current_seo_structured_data
          @_seo_structured_data || []
        end
      end
    end
  end
end
```

---

## Rails Generator: Install

```ruby
# lib/generators/better_seo/install_generator.rb
module BetterSeo
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Install BetterSeo in your Rails application"

      def create_initializer
        template "initializer.rb", "config/initializers/better_seo.rb"
      end

      def create_config
        template "better_seo.yml", "config/better_seo.yml"
      end

      def create_locale_directories
        empty_directory "config/locales/seo/it"
        empty_directory "config/locales/seo/en"
      end

      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end
```

---

## Checklist

- [ ] View helpers (meta_tags, open_graph, structured_data)
- [ ] Helper `render_seo_tags` (all-in-one)
- [ ] Controller concern `SeoAware`
- [ ] Method `set_seo` DSL in controllers
- [ ] Rails generators (install, config)
- [ ] Generator templates
- [ ] Rails Engine per routes
- [ ] Auto-include helpers in ApplicationHelper
- [ ] Auto-include concerns in ApplicationController
- [ ] Test coverage > 90%

---

**Prossimi Passi**: Step 06 - i18n Page Generator
