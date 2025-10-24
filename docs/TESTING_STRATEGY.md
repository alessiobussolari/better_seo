# BetterSeo - Strategia di Testing

Approccio completo per testing di BetterSeo con RSpec.

---

## Obiettivi Testing

### Coverage Goals

- **Target**: > 90% code coverage
- **Minimum**: 85% code coverage per release
- **Critical paths**: 100% coverage (configuration, generators, validators)

### Quality Goals

- ✅ Tutti i test passano (green) prima di merge
- ✅ Zero flaky tests
- ✅ Test performance < 30 secondi suite completa
- ✅ Isolamento completo tra test (no shared state)

---

## Test Pyramid

```
        /\
       /  \
      / E2E\ (5%)
     /______\
    /        \
   /Integration\ (25%)
  /____________\
 /              \
/   Unit Tests   \ (70%)
/_________________\
```

### Unit Tests (70%)
- DSL classes
- Generators
- Validators
- Configuration
- Helpers individuali

### Integration Tests (25%)
- Rails integration
- Generator + Validator flow
- Controller + Helper interaction
- Full SEO rendering pipeline

### E2E Tests (5%)
- Gem installation in dummy Rails app
- Full workflow da generator a HTML output
- Rake tasks end-to-end

---

## Setup Testing Environment

### spec/spec_helper.rb

```ruby
# frozen_string_literal: true

require "simplecov"
SimpleCov.start "rails" do
  add_filter "/spec/"
  add_filter "/vendor/"

  add_group "DSL", "lib/better_seo/dsl"
  add_group "Generators", "lib/better_seo/generators"
  add_group "Validators", "lib/better_seo/validators"
  add_group "Rails", "lib/better_seo/rails"
  add_group "Images", "lib/better_seo/images"

  minimum_coverage 90
end

require "better_seo"
require "rspec"
require "webmock/rspec"
require "vcr"

# Disable external HTTP requests
WebMock.disable_net_connect!(allow_localhost: true)

# VCR configuration
VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.default_cassette_options = { record: :new_episodes }
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = "spec/examples.txt"

  # Disable RSpec exposing methods globally
  config.disable_monkey_patching!

  # Use expect syntax
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Reset BetterSeo configuration before each test
  config.before(:each) do
    BetterSeo.reset_configuration!
  end

  # Random order
  config.order = :random
  Kernel.srand config.seed
end
```

### spec/rails_helper.rb

```ruby
# frozen_string_literal: true

require "spec_helper"

ENV["RAILS_ENV"] ||= "test"

# Dummy Rails app per testing
require File.expand_path("../dummy/config/environment", __FILE__)

require "rspec/rails"
require "factory_bot_rails"

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # FactoryBot
  config.include FactoryBot::Syntax::Methods

  # Rails helpers
  config.include ActionView::Helpers::TagHelper, type: :helper
  config.include ActionView::Context, type: :helper
end
```

---

## Testing Patterns

### 1. Unit Test - DSL Classes

```ruby
# spec/dsl/meta_tags_spec.rb
RSpec.describe BetterSeo::DSL::MetaTags do
  subject(:meta) { described_class.new }

  describe "#title" do
    it "sets title" do
      meta.title "My Title"
      expect(meta.title).to eq("My Title")
    end

    it "returns self for chaining" do
      expect(meta.title("Title")).to eq(meta)
    end

    context "when title too long" do
      it "raises validation error on build" do
        meta.title "A" * 80
        expect { meta.build }.to raise_error(BetterSeo::ValidationError)
      end
    end
  end

  describe "#build" do
    it "returns configuration hash" do
      meta.title "Title"
      meta.description "Description"

      result = meta.build

      expect(result).to eq({
        title: "Title",
        description: "Description"
      })
    end

    it "validates configuration" do
      # Validation logic tested
    end
  end
end
```

### 2. Unit Test - Generators

```ruby
# spec/generators/meta_tags_generator_spec.rb
RSpec.describe BetterSeo::Generators::MetaTagsGenerator do
  let(:config) do
    {
      charset: "UTF-8",
      title: "Test Page",
      description: "Test description"
    }
  end

  subject(:generator) { described_class.new(config) }

  describe "#generate" do
    subject(:html) { generator.generate }

    it "generates charset tag" do
      expect(html).to include('<meta charset="UTF-8">')
    end

    it "generates title tag" do
      expect(html).to include('<title>Test Page</title>')
    end

    it "generates description tag" do
      expect(html).to include('<meta name="description" content="Test description">')
    end

    context "with XSS attempt" do
      let(:config) { { title: '<script>alert("xss")</script>' } }

      it "escapes HTML entities" do
        expect(html).to include('&lt;script&gt;')
        expect(html).not_to include('<script>')
      end
    end

    context "with unicode characters" do
      let(:config) { { title: "Titolo con àccénti é ümläut" } }

      it "preserves unicode" do
        expect(html).to include("àccénti é ümläut")
      end
    end
  end
end
```

### 3. Integration Test - Configuration Loading

```ruby
# spec/integration/configuration_spec.rb
RSpec.describe "Configuration Loading", type: :integration do
  let(:yaml_content) do
    <<~YAML
      production:
        site_name: "Production Site"
        meta_tags:
          default_title: "Prod Title"
        sitemap:
          enabled: true
          host: "https://prod.example.com"
    YAML
  end

  let(:config_path) { "tmp/better_seo_test.yml" }

  before do
    File.write(config_path, yaml_content)
  end

  after do
    File.delete(config_path) if File.exist?(config_path)
  end

  it "loads configuration from YAML file" do
    BetterSeo.configure do |config|
      config.load_from_file(config_path, environment: :production)
    end

    expect(BetterSeo.configuration.site_name).to eq("Production Site")
    expect(BetterSeo.configuration.meta_tags.default_title).to eq("Prod Title")
    expect(BetterSeo.configuration.sitemap.host).to eq("https://prod.example.com")
  end

  it "validates after loading" do
    expect {
      BetterSeo.configure do |config|
        config.load_from_file(config_path, environment: :production)
      end
    }.not_to raise_error
  end
end
```

### 4. Integration Test - Rails Helpers

```ruby
# spec/helpers/meta_tags_helper_spec.rb
RSpec.describe BetterSeo::Rails::Helpers::MetaTagsHelper, type: :helper do
  before do
    BetterSeo.configure do |config|
      config.meta_tags.default_title = "Default Title"
      config.meta_tags.default_description = "Default Description"
    end
  end

  describe "#seo_meta_tags" do
    it "renders meta tags with defaults" do
      html = helper.seo_meta_tags

      expect(html).to include('<title>Default Title</title>')
      expect(html).to include('name="description" content="Default Description"')
    end

    it "accepts block for overrides" do
      html = helper.seo_meta_tags do |meta|
        meta.title "Custom Title"
      end

      expect(html).to include('<title>Custom Title</title>')
    end

    it "accepts hash options" do
      html = helper.seo_meta_tags(title: "Hash Title")

      expect(html).to include('<title>Hash Title</title>')
    end

    it "returns html_safe string" do
      html = helper.seo_meta_tags
      expect(html).to be_html_safe
    end
  end

  describe "#render_seo_tags" do
    it "renders all SEO tags when enabled" do
      BetterSeo.configuration.open_graph.enabled = true
      BetterSeo.configuration.twitter.enabled = true

      html = helper.render_seo_tags

      expect(html).to include('<title>')  # meta tags
      expect(html).to include('property="og:')  # open graph
      expect(html).to include('name="twitter:')  # twitter cards
    end
  end
end
```

### 5. E2E Test - Full Workflow

```ruby
# spec/e2e/full_seo_workflow_spec.rb
RSpec.describe "Full SEO Workflow", type: :feature do
  it "generates complete SEO markup from configuration" do
    # 1. Configure
    BetterSeo.configure do |config|
      config.site_name = "Test Site"

      config.meta_tags do
        default_title "Test Title"
        default_description "Test Description"
      end

      config.open_graph do
        site_name "Test Site"
        default_type "website"
      end
    end

    # 2. Build DSL
    meta_dsl = BetterSeo::DSL::MetaTags.new
    meta_dsl.title "Article Title"
    meta_dsl.description "Article Description"

    og_dsl = BetterSeo::DSL::OpenGraph.new
    og_dsl.title "Article Title"
    og_dsl.type "article"

    # 3. Generate HTML
    meta_html = BetterSeo::Generators::MetaTagsGenerator.new(meta_dsl.build).generate
    og_html = BetterSeo::Generators::OpenGraphGenerator.new(og_dsl.build).generate

    # 4. Verify output
    expect(meta_html).to include('<title>Article Title</title>')
    expect(og_html).to include('property="og:title" content="Article Title"')
    expect(og_html).to include('property="og:type" content="article"')
  end
end
```

---

## Fixtures e Factories

### FactoryBot Factories

```ruby
# spec/factories/articles.rb
FactoryBot.define do
  factory :article do
    title { "Test Article" }
    description { "Test Description" }
    published_at { Time.current }

    trait :with_seo do
      seo_title { "SEO Title" }
      seo_description { "SEO Description" }
      seo_keywords { ["ruby", "seo"] }
    end

    trait :published do
      published { true }
    end
  end
end
```

### Fixtures Files

```yaml
# spec/fixtures/config/better_seo.yml
test:
  site_name: "Test Site"
  default_locale: en
  available_locales:
    - en
    - it

  meta_tags:
    default_title: "Test Title"
    default_description: "Test Description"

  sitemap:
    enabled: false

  robots:
    enabled: false
```

---

## Shared Examples

```ruby
# spec/support/shared_examples/dsl_examples.rb
RSpec.shared_examples "a DSL builder" do
  it "responds to #build" do
    expect(subject).to respond_to(:build)
  end

  it "responds to #to_h" do
    expect(subject).to respond_to(:to_h)
  end

  it "responds to #merge!" do
    expect(subject).to respond_to(:merge!)
  end

  it "returns self for method chaining" do
    # Assume first_method exists
    expect(subject.send(described_class.instance_methods(false).first, "value")).to eq(subject)
  end
end

# Usage:
RSpec.describe BetterSeo::DSL::MetaTags do
  it_behaves_like "a DSL builder"
end
```

---

## Custom Matchers

```ruby
# spec/support/matchers/html_matchers.rb
RSpec::Matchers.define :have_meta_tag do |name, content|
  match do |html|
    html.include?(%(<meta name="#{name}" content="#{content}">))
  end

  failure_message do |html|
    "expected HTML to include meta tag '#{name}' with content '#{content}', but got:\n#{html}"
  end
end

# Usage:
expect(html).to have_meta_tag("description", "My Description")
```

---

## Testing Images (Step 07)

```ruby
# spec/images/converter_spec.rb
RSpec.describe BetterSeo::Images::Converter do
  let(:source_path) { "spec/fixtures/images/test.jpg" }
  let(:output_path) { "tmp/test.webp" }

  after do
    File.delete(output_path) if File.exist?(output_path)
  end

  describe ".to_webp" do
    it "converts JPEG to WebP", :vips do
      result = described_class.to_webp(source_path, output_path)

      expect(File.exist?(result)).to be true
      expect(result).to end_with(".webp")
    end

    it "reduces file size" do
      original_size = File.size(source_path)

      described_class.to_webp(source_path, output_path, quality: 80)

      webp_size = File.size(output_path)
      expect(webp_size).to be < original_size
    end
  end
end
```

---

## Performance Testing

```ruby
# spec/performance/generators_performance_spec.rb
RSpec.describe "Generators Performance" do
  it "generates meta tags in < 1ms" do
    config = { title: "Title", description: "Description" }
    generator = BetterSeo::Generators::MetaTagsGenerator.new(config)

    time = Benchmark.realtime do
      1000.times { generator.generate }
    end

    expect(time / 1000).to be < 0.001  # < 1ms per generation
  end

  it "generates sitemap for 10k URLs in < 1s" do
    urls = 10_000.times.map do |i|
      { loc: "https://example.com/page-#{i}", priority: 0.5 }
    end

    generator = BetterSeo::Generators::SitemapGenerator.new(urls)

    time = Benchmark.realtime { generator.generate }

    expect(time).to be < 1.0  # < 1 second
  end
end
```

---

## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/ci.yml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        ruby: ['3.0', '3.1', '3.2', '3.3']
        rails: ['6.1', '7.0', '7.1']

    steps:
      - uses: actions/checkout@v3

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ matrix.ruby }}
          bundler-cache: true

      - name: Install libvips
        run: sudo apt-get install libvips-dev

      - name: Run tests
        run: bundle exec rspec

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/.resultset.json
```

---

## Coverage Reports

### SimpleCov Configuration

```ruby
# spec/spec_helper.rb
SimpleCov.start "rails" do
  add_filter "/spec/"
  add_filter "/vendor/"

  add_group "DSL", "lib/better_seo/dsl"
  add_group "Generators", "lib/better_seo/generators"
  add_group "Validators", "lib/better_seo/validators"
  add_group "Rails", "lib/better_seo/rails"
  add_group "Images", "lib/better_seo/images"

  minimum_coverage 90
  refuse_coverage_drop

  # Formatters
  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::Console
  ])
end
```

### Viewing Coverage

```bash
# Run tests
bundle exec rspec

# Open coverage report
open coverage/index.html
```

---

## Best Practices

### ✅ DO

- Write tests BEFORE implementation (TDD)
- Use descriptive test names
- Test edge cases and error conditions
- Keep tests isolated (no shared state)
- Use factories for complex objects
- Mock external dependencies (HTTP, file system quando possibile)
- Test both happy path and sad path

### ❌ DON'T

- Don't test framework code (Rails, RSpec)
- Don't write flaky tests
- Don't share state between tests
- Don't use sleep in tests
- Don't skip tests (fix or delete)
- Don't test implementation details

---

**Ultima modifica**: 2025-10-22
