# Step 02: Meta Tags e Open Graph

**Versione Target**: 0.3.0
**Durata Stimata**: 2-3 settimane
**Priorità**: 🔴 CRITICA (Essential SEO)
**Dipendenze**: Step 01 completato

---

## Obiettivi dello Step

Implementare funzionalità SEO essenziali:

1. ✅ Meta tags HTML (title, description, keywords, robots, canonical)
2. ✅ Open Graph protocol completo
3. ✅ Twitter Cards
4. ✅ Validatori meta tags
5. ✅ HTML generators
6. ✅ Rails helpers base

---

## File da Creare

```
lib/better_seo/dsl/meta_tags.rb
lib/better_seo/dsl/open_graph.rb
lib/better_seo/dsl/twitter_cards.rb
lib/better_seo/generators/meta_tags_generator.rb
lib/better_seo/generators/open_graph_generator.rb
lib/better_seo/generators/twitter_cards_generator.rb
lib/better_seo/validators/meta_validator.rb
lib/better_seo/rails/helpers/meta_tags_helper.rb (partial)
lib/better_seo/rails/helpers/open_graph_helper.rb (partial)
```

---

## Implementazione: DSL Meta Tags

```ruby
# lib/better_seo/dsl/meta_tags.rb
module BetterSeo
  module DSL
    class MetaTags < Base
      def title(value = nil)
        value ? set(:title, value) : get(:title)
      end

      def description(value = nil)
        value ? set(:description, value) : get(:description)
      end

      def keywords(*values)
        values.any? ? set(:keywords, values.flatten) : get(:keywords)
      end

      def author(value = nil)
        value ? set(:author, value) : get(:author)
      end

      def canonical(value = nil)
        value ? set(:canonical, value) : get(:canonical)
      end

      def robots(index: true, follow: true, **options)
        set(:robots, { index: index, follow: follow }.merge(options))
      end

      def viewport(value = "width=device-width, initial-scale=1.0")
        set(:viewport, value)
      end

      def charset(value = "UTF-8")
        set(:charset, value)
      end

      protected

      def validate!
        errors = []

        if config[:title] && config[:title].length > 60
          errors << "Title too long (#{config[:title].length} chars, max 60 recommended)"
        end

        if config[:description] && config[:description].length > 160
          errors << "Description too long (#{config[:description].length} chars, max 160 recommended)"
        end

        raise ValidationError, errors.join(", ") if errors.any?
      end
    end
  end
end
```

---

## Implementazione: Generator Meta Tags

```ruby
# lib/better_seo/generators/meta_tags_generator.rb
module BetterSeo
  module Generators
    class MetaTagsGenerator
      def initialize(config)
        @config = config
      end

      def generate
        tags = []

        tags << charset_tag if @config[:charset]
        tags << viewport_tag if @config[:viewport]
        tags << title_tag if @config[:title]
        tags << description_tag if @config[:description]
        tags << keywords_tag if @config[:keywords]&.any?
        tags << author_tag if @config[:author]
        tags << robots_tag if @config[:robots]
        tags << canonical_tag if @config[:canonical]

        tags.compact.join("\n")
      end

      private

      def charset_tag
        %(<meta charset="#{escape(@config[:charset])}">)
      end

      def viewport_tag
        %(<meta name="viewport" content="#{escape(@config[:viewport])}">)
      end

      def title_tag
        %(<title>#{escape(@config[:title])}</title>)
      end

      def description_tag
        %(<meta name="description" content="#{escape(@config[:description])}">)
      end

      def keywords_tag
        keywords = Array(@config[:keywords]).join(", ")
        %(<meta name="keywords" content="#{escape(keywords)}">)
      end

      def author_tag
        %(<meta name="author" content="#{escape(@config[:author])}">)
      end

      def robots_tag
        robots = @config[:robots]
        parts = []
        parts << "index" if robots[:index]
        parts << "noindex" unless robots[:index]
        parts << "follow" if robots[:follow]
        parts << "nofollow" unless robots[:follow]

        %(<meta name="robots" content="#{parts.join(", ")}">)
      end

      def canonical_tag
        %(<link rel="canonical" href="#{escape(@config[:canonical])}">)
      end

      def escape(text)
        text.to_s.gsub('"', '&quot;').gsub('<', '&lt;').gsub('>', '&gt;')
      end
    end
  end
end
```

---

## Test Suite

```ruby
# spec/dsl/meta_tags_spec.rb
RSpec.describe BetterSeo::DSL::MetaTags do
  subject(:meta) { described_class.new }

  it "sets title" do
    meta.title "My Page Title"
    expect(meta.title).to eq("My Page Title")
  end

  it "validates title length" do
    meta.title "A" * 80
    expect { meta.build }.to raise_error(BetterSeo::ValidationError, /too long/)
  end

  it "sets robots directives" do
    meta.robots index: true, follow: false
    expect(meta.robots).to eq({ index: true, follow: false })
  end
end

# spec/generators/meta_tags_generator_spec.rb
RSpec.describe BetterSeo::Generators::MetaTagsGenerator do
  let(:config) do
    {
      charset: "UTF-8",
      title: "Test Page",
      description: "Test description",
      canonical: "https://example.com/test"
    }
  end

  subject(:generator) { described_class.new(config) }

  describe "#generate" do
    it "generates HTML meta tags" do
      html = generator.generate

      expect(html).to include('<meta charset="UTF-8">')
      expect(html).to include('<title>Test Page</title>')
      expect(html).to include('name="description"')
      expect(html).to include('rel="canonical"')
    end

    it "escapes HTML entities" do
      config[:title] = 'Test <script>alert("xss")</script>'
      html = generator.generate

      expect(html).to include('&lt;script&gt;')
      expect(html).not_to include('<script>')
    end
  end
end
```

---

## Checklist Completamento

- [ ] DSL MetaTags implementato e testato
- [ ] DSL OpenGraph implementato e testato
- [ ] DSL TwitterCards implementato e testato
- [ ] Generator MetaTags con HTML output
- [ ] Generator OpenGraph con property tags
- [ ] Generator TwitterCards
- [ ] Validatori per lunghezze ottimali
- [ ] Test coverage > 90%
- [ ] Integration con Step 01 Configuration

---

**Prossimi Passi**: Step 03 - Structured Data
