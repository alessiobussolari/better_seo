# Step 06: Generatore Pagine i18n

**Versione Target**: 0.7.0
**Durata Stimata**: 1-2 settimane
**Priorità**: 🟢 BASSA
**Dipendenze**: Step 01, 02, 05

---

## Obiettivi

1. ✅ Rails generator `rails g better_seo:page`
2. ✅ File YAML per locale in config/locales/seo/:locale/
3. ✅ Template per page types (website, article, product)
4. ✅ Helper `set_seo_from_locale`
5. ✅ Interpolazione variabili
6. ✅ Rake task validazione traduzioni

---

## File da Creare

```
lib/generators/better_seo/page_generator.rb
lib/generators/better_seo/page/templates/page_it.yml.tt
lib/generators/better_seo/page/templates/page_en.yml.tt
lib/better_seo/i18n/loader.rb
lib/better_seo/tasks/i18n.rake
```

---

## Implementazione: Page Generator

```ruby
# lib/generators/better_seo/page_generator.rb
module BetterSeo
  module Generators
    class PageGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      class_option :type, type: :string, default: "website",
        desc: "Type of page: website, article, product, organization"

      class_option :locales, type: :array,
        desc: "Locales to generate (default: from BetterSeo config)"

      class_option :skip_twitter, type: :boolean, default: false
      class_option :skip_open_graph, type: :boolean, default: false
      class_option :skip_structured_data, type: :boolean, default: false

      def create_locale_files
        locales.each do |locale|
          @locale = locale
          @page_type = options[:type]

          template_file = "page_#{locale}.yml"
          output_path = "config/locales/seo/#{locale}/#{file_name}.yml"

          template template_file, output_path
        end
      end

      private

      def locales
        options[:locales] || BetterSeo.configuration.available_locales
      end

      def translations
        # Template-specific translations
        case @locale.to_sym
        when :it
          {
            title: "Titolo Pagina",
            description: "Descrizione per motori di ricerca",
            keywords: ["parola1", "parola2"]
          }
        when :en
          {
            title: "Page Title",
            description: "Description for search engines",
            keywords: ["keyword1", "keyword2"]
          }
        end
      end
    end
  end
end
```

---

## Template YAML

```yaml
# lib/generators/better_seo/page/templates/page_it.yml.tt
it:
  seo:
    pages:
      <%= file_name %>:
        meta:
          title: "<%= translations[:title] %>"
          description: "<%= translations[:description] %>"
          keywords: <%= translations[:keywords].to_yaml.sub("---\n", "") %>

        <% unless options[:skip_open_graph] %>
        open_graph:
          title: "<%= translations[:title] %>"
          description: "<%= translations[:description] %>"
          type: "<%= @page_type %>"
          image:
            url: "https://example.com/images/og-<%= file_name %>-it.jpg"
            width: 1200
            height: 630
        <% end %>

        <% unless options[:skip_twitter] %>
        twitter:
          card: "summary_large_image"
          title: "<%= translations[:title] %>"
          description: "<%= translations[:description] %>"
        <% end %>

        <% unless options[:skip_structured_data] %>
        structured_data:
          type: "<%= structured_data_type %>"
          data:
            name: "<%= translations[:title] %>"
        <% end %>
```

---

## Helper set_seo_from_locale

```ruby
# Aggiunto a lib/better_seo/rails/concerns/seo_aware.rb

def set_seo_from_locale(page_name, &block)
  locale_key = "seo.pages.#{page_name}"

  # Load from i18n
  meta_data = I18n.t("#{locale_key}.meta", default: {})
  og_data = I18n.t("#{locale_key}.open_graph", default: {})
  sd_data = I18n.t("#{locale_key}.structured_data", default: {})

  # Build SEO config
  set_seo do |seo|
    seo.merge!(meta_data)

    # Open Graph
    seo.open_graph do |og|
      og.merge!(og_data)
    end

    # Structured Data
    if sd_data[:type]
      seo.structured_data sd_data[:type].underscore.to_sym do |sd|
        sd.merge!(sd_data[:data] || {})
      end
    end
  end

  # Apply block overrides
  yield(@_seo_builder) if block_given?
end
```

---

## Rake Task Validazione

```ruby
# lib/better_seo/tasks/i18n.rake
namespace :better_seo do
  namespace :i18n do
    desc "Validate SEO translations across locales"
    task validate: :environment do
      locales = BetterSeo.configuration.available_locales
      base_locale = locales.first

      I18n.backend.load_translations

      # Get all page keys from base locale
      base_keys = I18n.t("seo.pages", locale: base_locale).keys

      errors = []

      base_keys.each do |page_key|
        locales.each do |locale|
          begin
            page_data = I18n.t("seo.pages.#{page_key}", locale: locale)

            # Check required keys
            unless page_data.dig(:meta, :title)
              errors << "Missing meta.title in #{locale}:seo.pages.#{page_key}"
            end
          rescue I18n::MissingTranslationData
            errors << "Missing translation for #{locale}:seo.pages.#{page_key}"
          end
        end
      end

      if errors.any?
        puts "✗ Validation failed:\n"
        errors.each { |e| puts "  - #{e}" }
        exit 1
      else
        puts "✓ All SEO translations validated successfully"
      end
    end
  end
end
```

---

## Checklist

- [ ] Page generator con templates
- [ ] Template YAML per IT e EN
- [ ] Support page types (website, article, product)
- [ ] Options (--skip-twitter, --skip-open-graph, etc.)
- [ ] Helper `set_seo_from_locale`
- [ ] Interpolazione variabili (%{name})
- [ ] Rake task `better_seo:i18n:validate`
- [ ] Test generator output
- [ ] Documentation esempi

---

**Prossimi Passi**: Step 07 - Image Optimization
