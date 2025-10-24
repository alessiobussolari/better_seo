# Step 03: Structured Data (JSON-LD)

**Versione Target**: 0.4.0
**Durata Stimata**: 2-3 settimane
**Priorità**: 🟡 MEDIA
**Dipendenze**: Step 01

---

## Obiettivi

1. ✅ Schema.org types (Article, Product, Organization, Person, Breadcrumb)
2. ✅ JSON-LD generator
3. ✅ DSL per structured data
4. ✅ Schema validator
5. ✅ Multiple structured data per page

---

## File da Creare

```
lib/better_seo/schema/base.rb
lib/better_seo/schema/article.rb
lib/better_seo/schema/product.rb
lib/better_seo/schema/organization.rb
lib/better_seo/schema/person.rb
lib/better_seo/schema/breadcrumb.rb
lib/better_seo/generators/json_ld_generator.rb
lib/better_seo/dsl/structured_data.rb
lib/better_seo/validators/schema_validator.rb
```

---

## Implementazione: Schema Article

```ruby
# lib/better_seo/schema/article.rb
module BetterSeo
  module Schema
    class Article < Base
      def schema_type
        "Article"
      end

      def headline(value = nil)
        value ? set(:headline, value) : get(:headline)
      end

      def date_published(value = nil)
        value ? set(:datePublished, format_date(value)) : get(:datePublished)
      end

      def date_modified(value = nil)
        value ? set(:dateModified, format_date(value)) : get(:dateModified)
      end

      def author(&block)
        if block_given?
          person = Person.new
          person.evaluate(&block)
          set(:author, person.to_schema)
        else
          get(:author)
        end
      end

      def publisher(&block)
        if block_given?
          org = Organization.new
          org.evaluate(&block)
          set(:publisher, org.to_schema)
        else
          get(:publisher)
        end
      end

      def to_schema
        {
          "@context" => "https://schema.org",
          "@type" => schema_type
        }.merge(config)
      end

      private

      def format_date(value)
        return value if value.is_a?(String)
        value.respond_to?(:iso8601) ? value.iso8601 : value.to_s
      end
    end
  end
end
```

---

## Implementazione: JSON-LD Generator

```ruby
# lib/better_seo/generators/json_ld_generator.rb
require "json"

module BetterSeo
  module Generators
    class JsonLdGenerator
      def initialize(schema_data)
        @schema_data = Array(schema_data)
      end

      def generate
        return "" if @schema_data.empty?

        scripts = @schema_data.map do |schema|
          json = JSON.pretty_generate(schema)
          %(<script type="application/ld+json">\n#{json}\n</script>)
        end

        scripts.join("\n")
      end
    end
  end
end
```

---

## Checklist

- [ ] Schema base types (Article, Product, Organization, Person, Breadcrumb)
- [ ] JSON-LD generator
- [ ] DSL structured_data
- [ ] Schema validator (schema.org compliance)
- [ ] Support multiple schemas per page
- [ ] Test coverage > 90%

---

**Prossimi Passi**: Step 04 - Sitemap & Robots
