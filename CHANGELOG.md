# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0.1] - 2025-01-24

### Fixed
- Fixed nested configuration setters to support syntax like `config.open_graph.default_image.url = "value"`
  - Modified `NestedConfiguration#initialize` to automatically wrap nested hashes
  - Modified `NestedConfiguration#[]=` to wrap hash values
  - Modified `NestedConfiguration#method_missing` setter to wrap hash values
  - Modified `NestedConfiguration#merge!` to wrap nested hashes after merge
  - Modified `NestedConfiguration#to_h` to recursively convert back to plain hashes
- Fixed SEO helper to automatically merge with configuration defaults
  - Added `build_seo_config` private method in `SeoHelper`
  - Automatic site_name appending to titles when configured
  - Automatic generation of Open Graph and Twitter Card tags with defaults
  - Support for `default_title` when not set in controller
- Fixed Railtie loading by adding require in `lib/better_seo.rb`
- Updated README with improved footer (Made with ❤️ by Alessio Bussolari)
- Removed Roadmap section from README (version history moved to CHANGELOG)

### Added
- 17 new tests for nested configuration hash wrapping
  - Tests for initialization, assignment, merge, and edge cases
  - Real-world generator template syntax tests
  - Total: 916 tests passing (899 + 17)

### Enhanced
- Improved user experience with automatic defaults in SEO tags
- Better configuration system with deep nested object support
- More intuitive initializer template generation

## [1.0.0] - 2025-01-23 🎉

### 🚀 First Stable Release - Production Ready!

BetterSeo v1.0.0 is a comprehensive, production-ready SEO gem for Ruby and Rails applications.

### Highlights

- **899 tests passing** with **94.3% code coverage**
- **Strict TDD methodology** - Every feature developed with RED → GREEN → REFACTOR
- **Complete SEO toolkit** - Meta tags, structured data, sitemaps, analytics, validation
- **Enterprise-ready** - GTM integration, image optimization, SEO recommendations
- **Rails-first** - Deep Rails integration with helpers, generators, and railtie
- **Well documented** - Comprehensive README with 100+ examples

### What's Included

**Core SEO Features:**
- Meta tags DSL (title, description, keywords, robots, canonical)
- Open Graph protocol (complete implementation)
- Twitter Cards (all card types)
- 10+ Structured Data types (Schema.org JSON-LD)
- XML Sitemaps with extensions (hreflang, images, videos, sitemap index)

**Advanced Features:**
- Robots.txt generator
- SEO Validator with scoring (0-100)
- AI-powered SEO recommendations
- Image optimizer (WebP conversion, resize, compress)
- Breadcrumbs HTML generator with Schema.org
- AMP HTML support
- Canonical URL management

**Analytics & Tracking:**
- Google Analytics 4 (GA4) integration
- Google Tag Manager (GTM) complete setup
- E-commerce tracking
- Custom event tracking
- GDPR-compliant (anonymize IP)

**Rails Integration:**
- View helpers for all features
- Controller helpers (set_page_title, set_page_description, etc.)
- Model helpers (seo_attributes macro)
- Install generator (`rails g better_seo:install`)
- Automatic railtie initialization

### Migration from v0.14.0

No breaking changes. Simply update your Gemfile:

```ruby
gem 'better_seo', '~> 1.0'
```

### Thank You!

This gem was developed with **strict Test-Driven Development** through 14 development steps, implementing every feature with comprehensive test coverage. Special thanks to the Ruby and Rails communities for their excellent tools and documentation.

---

## [0.14.0] - 2025-01-23

### Added
- SEO Intelligence & Advanced Analytics features
  - **Google Tag Manager** (`BetterSeo::Analytics::GoogleTagManager`)
    - `to_head_script(nonce:)` - Generate GTM head script tag
    - `to_body_noscript` - Generate GTM body noscript fallback
    - `push_data_layer(**data)` - Push custom data to data layer
    - `push_ecommerce(event:, ecommerce:)` - Push e-commerce events
    - `push_user_data(**user_data)` - Push user information
    - Custom data layer name support
    - CSP nonce support for Content Security Policy
    - Complete GTM integration for enterprise analytics
  - **SEO Recommendations Engine** (`BetterSeo::Validators::SeoRecommendations`)
    - `generate_recommendations(validation_result)` - AI-powered SEO suggestions
    - `recommend_title_improvements(title_result)` - Title optimization tips
    - `recommend_description_improvements(desc_result)` - Description enhancements
    - `recommend_heading_improvements(headings_result)` - Heading structure fixes
    - `recommend_image_improvements(images_result)` - Image alt text suggestions
    - `format_recommendations(recommendations)` - Markdown formatted output
    - Priority-based recommendations (high, medium, low)
    - Actionable improvement steps with details
    - Integration with SEO Validator

### Enhanced
- Analytics module expanded with GTM support
- Validators module enhanced with intelligent recommendations
- Comprehensive SEO improvement workflow

### Test Coverage
- 899 tests passing (+25 from v0.13.0)
- 94.3% code coverage (1817/1926 lines)
- 25 new tests across intelligence features:
  - Google Tag Manager: 11 tests
  - SEO Recommendations: 14 tests

## [0.13.0] - 2025-01-23

### Added
- Advanced SEO Tools for validation and content management
  - **Robots.txt Generator** (`BetterSeo::Generators::RobotsTxtGenerator`)
    - `add_rule(user_agent, allow:, disallow:)` - Add robot directives
    - `set_crawl_delay(user_agent, seconds)` - Set crawl delay for bots
    - `add_sitemap(url)` - Add sitemap references
    - `clear` - Remove all rules and sitemaps
    - `to_text` - Generate robots.txt content
    - `write_to_file(path)` - Write robots.txt to file
    - Support for multiple user agents (*, Googlebot, Bingbot, etc.)
    - Allow/Disallow path directives
    - Automatic directory creation
    - Method chaining for fluent API
  - **SEO Validator** (`BetterSeo::Validators::SeoValidator`)
    - `check_title(text)` - Validate title length (30-60 chars optimal)
    - `check_description(text)` - Validate description length (120-160 chars optimal)
    - `check_headings(html)` - Validate H1-H6 structure
    - `check_images(html)` - Validate image alt text presence
    - `validate_page(html)` - Complete page validation
    - `generate_report(validation)` - Human-readable SEO report
    - Overall SEO score (0-100) with weighted components
    - Detailed issue tracking and recommendations
    - Warning levels for sub-optimal content
    - HTML parsing for meta tags extraction

### Enhanced
- Validators module introduced for SEO quality checks
- Comprehensive validation rules following SEO best practices
- Detailed error messages with actionable recommendations

- **Image Optimizer** (`BetterSeo::Image::Optimizer`)
    - `validate_format!(path)` - Validate image format (JPEG, PNG, WebP, GIF)
    - `convert_to_webp(source, destination)` - Convert images to WebP format
    - `resize(source, destination, width:, height:)` - Resize images
    - `compress(source, destination)` - Compress images with quality setting
    - `generate_responsive(source, output_dir, sizes:)` - Generate multiple sizes
    - `optimize(source, destination, resize:)` - Complete optimization with statistics
    - Requires ImageMagick and mini_magick gem
    - Quality control (0-100)
    - Optimization statistics (size reduction percentage)
  - **Analytics Integration** (`BetterSeo::Analytics::GoogleAnalytics`)
    - `to_script_tag(nonce:, **config)` - Generate GA4 script tag
    - `track_event(event_name, **parameters)` - Custom event tracking
    - `track_page_view(page_path, title:)` - Page view tracking
    - `ecommerce_purchase(transaction_id:, value:, items:)` - E-commerce tracking
    - Anonymize IP support for GDPR compliance
    - CSP nonce support for Content Security Policy
    - Custom configuration options

### Test Coverage
- 874 tests passing (+63 from v0.12.0)
- 94.1% code coverage (1723/1831 lines)
- 63 new tests across all advanced features:
  - Robots.txt Generator: 25 tests
  - SEO Validator: 22 tests
  - Image Optimizer: 5 tests (+ ImageMagick-dependent)
  - Google Analytics: 11 tests

## [0.12.0] - 2025-01-23

### Added
- Advanced HTML Generators for modern web applications
  - **BreadcrumbsGenerator** (`BetterSeo::Generators::BreadcrumbsGenerator`)
    - `add_item(name, url)` - Add single breadcrumb item
    - `add_items(array)` - Add multiple items at once
    - `clear` - Remove all items
    - `to_html(schema:, nav_class:, list_class:)` - Generate HTML breadcrumbs
    - `to_json_ld` - Generate JSON-LD structured data
    - `to_script_tag` - Generate script tag with JSON-LD
    - Schema.org microdata support with `schema: true` option
    - Custom CSS classes for nav and list elements
    - Automatic position numbering for structured data
    - Current page support (items without URLs)
    - HTML entity escaping for security
  - **AMP Generator** (`BetterSeo::Generators::AmpGenerator`)
    - `to_boilerplate` - Generate required AMP boilerplate CSS
    - `to_amp_script_tag` - Generate AMP runtime script tag
    - `to_meta_tags` - Generate canonical and OG meta tags
    - `to_structured_data` - Generate JSON-LD script tag
    - `to_custom_css(css)` - Wrap custom CSS in amp-custom style tag
    - Support for canonical URL, title, description, image
    - Structured data integration for AMP pages
    - Complete AMP HTML page support
  - **Canonical URL Manager** (`BetterSeo::Generators::CanonicalUrlManager`)
    - `to_html` - Generate canonical link HTML tag
    - `to_http_header` - Generate Link HTTP header
    - `validate!` - Validate canonical URL format and structure
    - URL normalization features:
      - Remove trailing slashes (preserves root URL)
      - Remove fragment identifiers automatically
      - Optional query parameter removal
      - Optional URL lowercasing
    - Validation for absolute URLs only
    - HTTP/HTTPS protocol validation
    - HTML entity escaping

### Enhanced
- HTML Generators section in README with comprehensive examples
- Documentation for all three new generators
- Rails integration examples for each generator

### Test Coverage
- 811 tests passing (+69 from v0.11.0)
- 96.41% code coverage (1506/1562 lines)
- 69 new tests across advanced generators:
  - BreadcrumbsGenerator: 21 tests
  - AMP Generator: 22 tests
  - Canonical URL Manager: 26 tests

## [0.11.0] - 2025-01-23

### Added
- Advanced Sitemap Features for large and international sites
  - **Multi-language Support (hreflang)**
    - `UrlEntry#add_alternate(href, hreflang:)` - Add alternate language versions
    - Support for region-specific alternates (en-US, en-GB, etc.)
    - x-default alternate support for default language
    - Automatic xhtml:link tag generation in XML
    - Method chaining for adding multiple alternates
  - **Image Sitemap Extensions**
    - `UrlEntry#add_image(loc, title:, caption:)` - Add images to URLs
    - Support for multiple images per URL
    - Automatic image:image tag generation
    - Optional title and caption metadata
  - **Video Sitemap Extensions**
    - `UrlEntry#add_video(thumbnail_loc:, title:, description:, content_loc:, duration:)` - Add videos to URLs
    - Support for multiple videos per URL
    - Automatic video:video tag generation
    - Optional duration metadata
  - **Sitemap Index** (`BetterSeo::Sitemap::SitemapIndex`)
    - Manage large sites with 50,000+ URLs
    - Split sitemaps across multiple files
    - `add_sitemap(loc, lastmod:)` - Add sitemaps to index
    - `to_xml` - Generate sitemapindex XML
    - `write_to_file(path)` - Write index to file
    - Automatic directory creation

### Enhanced
- `UrlEntry` now supports alternates, images, and videos arrays
- `UrlEntry#to_xml` includes all extensions (hreflang, images, videos)
- `UrlEntry#to_h` includes alternates when present

### Test Coverage
- 742 tests passing (+35 from v0.10.0)
- 96.12% code coverage (1364/1419 lines)
- 35 new tests across advanced sitemap features:
  - Hreflang support: 11 tests
  - SitemapIndex: 12 tests
  - Image/Video extensions: 12 tests

## [0.10.0] - 2025-01-23

### Added
- Advanced Rails Integration for seamless framework integration
  - **Controller Helpers** (`BetterSeo::Rails::Helpers::ControllerHelpers`)
    - `set_page_title(title, prefix:, suffix:)` - Set page title with optional prefix/suffix
    - `set_page_description(description, max_length:)` - Set description with auto-truncation
    - `set_page_keywords(keywords)` - Set keywords from array or comma-separated string
    - `set_page_image(url, width:, height:)` - Set OG and Twitter image with dimensions
    - `set_canonical(url)` - Set canonical URL
    - `set_noindex(nofollow:)` - Set noindex robot directive
    - `set_meta_tags(data)` - Set custom meta tags (hash or block)
    - `set_og_tags(data)` - Set Open Graph tags (hash or block)
    - `set_twitter_tags(data)` - Set Twitter Card tags (hash or block)
    - `better_seo_data` - Access all stored SEO data
  - **Model Helpers** (`BetterSeo::Rails::ModelHelpers`)
    - `seo_attributes(mappings)` - Class macro for defining SEO attribute mappings
    - Support for symbol, proc, and direct value mappings
    - `seo_title`, `seo_description`, `seo_keywords`, etc. - Auto-generated accessor methods
    - `to_seo_hash` - Convert model to SEO hash for easy controller integration
  - **Railtie** (`BetterSeo::Rails::Railtie`)
    - Automatic helper injection into ActionController
    - Automatic view helper injection into ActionView
    - No manual configuration required
  - **Install Generator** (`rails generate better_seo:install`)
    - Creates `config/initializers/better_seo.rb` with comprehensive defaults
    - Includes examples for all configuration options
    - Shows usage instructions after installation

### Enhanced
- Controller helpers now available as `helper_method` in views
- All helpers support both hash and block syntax for flexibility
- SEO data stored in controller instance variable accessible in views

### Test Coverage
- 707 tests passing (+38 from v0.9.0)
- 95.99% code coverage (1293/1347 lines)
- 38 new tests across Rails integration:
  - ControllerHelpers: 26 tests
  - ModelHelpers: 12 tests

## [0.9.0] - 2025-01-23

### Added
- Five additional Structured Data types for comprehensive SEO coverage
  - `StructuredData::LocalBusiness` - Physical business locations
    - Complete address with PostalAddress schema
    - Geographic coordinates with GeoCoordinates
    - Opening hours (string and structured specification)
    - Price range and cuisine information
    - Aggregate ratings for customer reviews
  - `StructuredData::Event` - Conferences, webinars, and events
    - Event dates with Date/Time/DateTime support
    - Event status (EventScheduled, EventCancelled, EventPostponed, EventRescheduled)
    - Event attendance mode (Offline, Online, Mixed)
    - Physical and virtual locations with Place/VirtualLocation
    - Organizer (Organization or Person)
    - Multiple ticket offers with pricing and availability
    - Performer support (single or multiple)
  - `StructuredData::FAQPage` - Structured FAQ pages
    - Add single or multiple questions
    - Automatic Question/Answer schema formatting
    - Clear method to reset questions
    - Rich snippets support in search results
  - `StructuredData::HowTo` - Step-by-step guides
    - Named steps with descriptions
    - Automatic position numbering
    - Supply and tool lists
    - Total time estimation
    - Step images and URLs
  - `StructuredData::Recipe` - Cooking recipes
    - Ingredients list management
    - Step-by-step instructions with HowToStep format
    - Prep time, cook time, total time
    - Recipe yield, category, cuisine
    - Nutrition information with NutritionInformation schema
    - Aggregate ratings
    - Keywords support
- Generator helper methods for all new types
  - `Generator.local_business` with block support
  - `Generator.event` with block support
  - `Generator.faq_page` with block support
  - `Generator.how_to` with block support
  - `Generator.recipe` with block support
- Rails view helpers for all new types
  - `local_business_sd(**properties, &block)`
  - `event_sd(**properties, &block)`
  - `faq_page_sd(questions:, &block)` - with array support
  - `how_to_sd(steps:, &block)` - with array support
  - `recipe_sd(ingredients:, instructions:, &block)` - with array support
- Enhanced TYPE_MAPPING in StructuredDataHelper with all 10 types

### Test Coverage
- 669 tests passing (+117 from v0.8.0)
- 95.79% code coverage (1205/1258 lines)
- 117 new tests across 5 structured data types:
  - LocalBusiness: 25 tests
  - Event: 36 tests
  - FAQPage: 11 tests
  - HowTo: 18 tests
  - Recipe: 27 tests

## [0.8.0] - 2025-01-23

### Added
- Rails Structured Data View Helpers for easy integration
  - `structured_data_tag(type, **properties, &block)` - Generic helper with type symbol or object
  - `organization_sd(**properties, &block)` - Organization structured data helper
  - `article_sd(**properties, &block)` - Article structured data helper
  - `person_sd(**properties, &block)` - Person structured data helper
  - `product_sd(**properties, &block)` - Product structured data helper
  - `breadcrumb_list_sd(items:, &block)` - Breadcrumb list structured data helper
  - `structured_data_tags(array)` - Multiple structured data tags generation
- Helper features
  - Support for both hash configuration and block-based DSL
  - Type mapping with symbol-based factory methods
  - Automatic HTML safety with `raw` method
  - Pass existing structured data objects or create on-the-fly
  - Seamless integration with Rails views and layouts
- Complete Rails integration examples
  - Product page with breadcrumbs and structured data
  - Helper method reference table
  - Type-specific helper examples

### Test Coverage
- 552 tests passing (+22 from v0.7.0)
- 98.83% code coverage (931/942 lines)
- 22 new tests for StructuredDataHelper

## [0.7.0] - 2025-01-23

### Added
- Additional Structured Data types for e-commerce and navigation
  - `StructuredData::Product` - E-commerce products with comprehensive schema
  - `StructuredData::BreadcrumbList` - Navigation breadcrumbs for site structure
- Product features
  - Full product information (name, description, image, brand)
  - SKU, GTIN, MPN identifiers support
  - Offers with price, currency, availability (InStock, OutOfStock, PreOrder, etc.)
  - Multiple offers support for variants
  - Aggregate ratings with review count
  - Individual reviews with author and rating
  - Multiple reviews array support
  - Availability URL mapping to Schema.org standards
- BreadcrumbList features
  - Add single items with `add_item`
  - Add multiple items with `add_items`
  - Automatic position numbering
  - Manual position override support
  - Clear all items with `clear`
  - Fluent method chaining
  - Generates proper ListItem structure
- Generator helper methods
  - `Generator.product` factory method with block support
  - `Generator.breadcrumb_list` factory method
- Rails integration examples
  - Product page structured data helpers
  - Breadcrumb integration with Rails routes
  - E-commerce view helpers

### Test Coverage
- 530 tests passing (+39 from v0.6.0)
- 98.89% code coverage (894/904 lines)
- 39 new tests for Product and BreadcrumbList

## [0.6.0] - 2025-01-23

### Added
- Structured Data (JSON-LD) support with comprehensive Schema.org implementation
  - `StructuredData::Base` - Generic base class for all structured data types
  - `StructuredData::Organization` - Company/organization information with full schema support
  - `StructuredData::Article` - Blog posts, news articles with author/publisher metadata
  - `StructuredData::Person` - Author profiles, team members with social links
  - `StructuredData::Generator` - Helper class with factory methods
- Structured data features
  - Fluent API with method chaining for all types
  - Automatic nested object handling (Person within Article, etc.)
  - JSON-LD generation with `to_json` and `to_script_tag` methods
  - Schema.org compliant output format
  - Address handling with PostalAddress schema
  - Social profile links with sameAs property
- Rails integration patterns
  - View helpers for structured data
  - Layout integration examples
  - Complete production examples
- Comprehensive documentation
  - 300+ lines of structured data documentation in README
  - Complete examples for Organization, Article, Person
  - Rails integration patterns and helper methods
  - Nested data examples

### Test Coverage
- 491 tests passing (+107 from v0.5.0)
- 99.64% code coverage (820/823 lines)
- 117 new tests for structured data functionality

## [0.5.0] - 2025-01-23

### Added
- Sitemap generation system with comprehensive XML sitemap support
  - `Sitemap::UrlEntry` - Individual URL entry with full sitemap.org protocol support
  - `Sitemap::Builder` - Fluent API for building sitemaps with method chaining
  - `Sitemap::Generator` - High-level generator with multiple generation strategies
- Sitemap generation methods
  - `generate` - Generate from block with fluent builder
  - `generate_from` - Generate from array of URLs
  - `generate_from_collection` - Generate from model collections with lambda support
  - `write_to_file` - Write sitemap directly to file with automatic directory creation
- URL entry features
  - Support for all sitemap attributes: loc, lastmod, changefreq, priority
  - Automatic date formatting (Date, Time, DateTime objects)
  - XML entity escaping for security
  - Validation for URL format, protocol (HTTP/HTTPS), and required fields
- Dynamic attribute generation
  - Lambda/Proc support for dynamic lastmod, changefreq, and priority
  - Conditional logic based on model attributes
- Rails integration examples
  - Controller actions for dynamic sitemap serving
  - Rake tasks for sitemap generation
  - Service object patterns for production use
  - Multi-model sitemap examples
- Comprehensive error handling
  - 28 error class tests added
  - Full coverage of all error types

### Test Coverage
- 384 tests passing (+98 from v0.4.0)
- 99.71% code coverage (681/683 lines)
- 69 new tests for sitemap functionality

## [0.4.0] - 2025-01-23

### Added
- Rails view helpers for easy integration
  - `seo_meta_tags` - Generate HTML meta tags
  - `seo_open_graph_tags` - Generate Open Graph tags
  - `seo_twitter_tags` - Generate Twitter Card tags
  - `seo_tags` - Generate all SEO tags at once
- Support for both hash configuration and DSL blocks in helpers
- Automatic HTML safety with `raw` helper
- Controller integration patterns and examples
- Complete Rails integration documentation

### Test Coverage
- 286 tests passing
- 100% code coverage (562/562 lines)

## [0.3.0] - 2025-01-23

### Added
- HTML Generators for converting DSL to HTML tags
  - `MetaTagsGenerator` - Converts meta tags DSL to HTML
  - `OpenGraphGenerator` - Converts Open Graph DSL to HTML
  - `TwitterCardsGenerator` - Converts Twitter Cards DSL to HTML
- HTML entity escaping for security (XSS prevention)

### Test Coverage
- 271 tests passing
- 100% code coverage (505/505 lines)

## [0.2.0] - 2025-01-22

### Added
- DSL Builders for creating SEO configurations
  - `DSL::MetaTags` - For HTML meta tags
  - `DSL::OpenGraph` - For Open Graph protocol
  - `DSL::TwitterCards` - For Twitter Cards
- Fluent interface with method chaining
- Automatic validation for all DSL builders

### Test Coverage
- 175 tests passing
- 100% code coverage (327/327 lines)

## [0.1.0] - 2025-01-22

### Added
- Core configuration system with singleton pattern
- Nested configuration objects
- Feature flags for enabling/disabling modules
- Validation with detailed error messages
- i18n support with multiple locales
- Custom error classes

### Test Coverage
- 74 tests passing
- 100% code coverage (179/179 lines)
