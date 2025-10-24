# Step 04: Sitemap XML e Robots.txt

**Versione Target**: 0.5.0
**Durata Stimata**: 1-2 settimane
**Priorità**: 🟡 MEDIA
**Dipendenze**: Step 01

---

## Obiettivi

1. ✅ Sitemap XML generator
2. ✅ Dynamic sitemap from Rails models
3. ✅ Sitemap index (>50k URLs)
4. ✅ Robots.txt generator
5. ✅ Ping search engines
6. ✅ Rake tasks

---

## File da Creare

```
lib/better_seo/generators/sitemap_generator.rb
lib/better_seo/generators/robots_generator.rb
lib/better_seo/tasks/sitemap.rake
lib/better_seo/tasks/robots.rake
lib/better_seo/sitemap/url_builder.rb
lib/better_seo/sitemap/index_builder.rb
```

---

## Implementazione: Sitemap Generator

```ruby
# lib/better_seo/generators/sitemap_generator.rb
require "builder"

module BetterSeo
  module Generators
    class SitemapGenerator
      def initialize(urls, options = {})
        @urls = urls
        @options = options
      end

      def generate
        xml = Builder::XmlMarkup.new(indent: 2)
        xml.instruct! :xml, version: "1.0", encoding: "UTF-8"

        xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
          @urls.each do |url_data|
            xml.url do
              xml.loc url_data[:loc]
              xml.lastmod url_data[:lastmod] if url_data[:lastmod]
              xml.changefreq url_data[:changefreq] if url_data[:changefreq]
              xml.priority url_data[:priority] if url_data[:priority]
            end
          end
        end

        xml.target!
      end

      def save(path)
        File.write(path, generate)
      end
    end
  end
end
```

---

## Rake Tasks

```ruby
# lib/better_seo/tasks/sitemap.rake
namespace :better_seo do
  namespace :sitemap do
    desc "Generate sitemap.xml"
    task generate: :environment do
      config = BetterSeo.configuration.sitemap

      urls = []

      # Add static URLs
      urls << { loc: "#{config.host}/", priority: 1.0, changefreq: "daily" }

      # Add dynamic URLs from models (configured in better_seo.yml)
      # Article.published.each do |article|
      #   urls << {
      #     loc: "#{config.host}#{article_path(article)}",
      #     lastmod: article.updated_at.iso8601,
      #     changefreq: "weekly",
      #     priority: 0.8
      #   }
      # end

      generator = BetterSeo::Generators::SitemapGenerator.new(urls)
      generator.save(config.output_path)

      puts "✓ Sitemap generated: #{config.output_path}"
    end

    desc "Generate and ping search engines"
    task generate_and_ping: :generate do
      # Ping Google, Bing, etc.
      puts "✓ Pinged search engines"
    end
  end
end
```

---

## Checklist

- [ ] Sitemap XML generator con Builder
- [ ] Dynamic URLs from models
- [ ] Sitemap index per >50k URLs
- [ ] Robots.txt generator
- [ ] Rake tasks (generate, ping)
- [ ] Gzip compression opzionale
- [ ] Image sitemap support
- [ ] Test coverage > 85%

---

**Prossimi Passi**: Step 05 - Rails Integration
