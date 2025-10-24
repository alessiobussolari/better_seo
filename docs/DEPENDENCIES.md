# BetterSeo - Dipendenze

Elenco completo di gem e system dependencies necessarie per BetterSeo.

---

## Ruby Version

**Richiesto**: Ruby >= 3.0.0

**Testato su**:
- Ruby 3.0.x
- Ruby 3.1.x
- Ruby 3.2.x
- Ruby 3.3.x

---

## Gem Dependencies

### Runtime Dependencies

Aggiunte al `better_seo.gemspec`:

```ruby
spec.add_dependency "activesupport", ">= 6.1"
```
- **Uso**: HashWithIndifferentAccess, Concerns, Core Extensions
- **Richiesto per**: Configuration, DSL, Rails integration

```ruby
spec.add_dependency "image_processing", "~> 1.12"
```
- **Uso**: Image optimization wrapper
- **Richiesto per**: Step 07 (Image Optimization)
- **Opzionale**: Può essere rimosso se images non utilizzate

```ruby
spec.add_dependency "ruby-vips", "~> 2.1"
```
- **Uso**: WebP conversion, image resizing
- **Richiesto per**: Step 07 (Image Optimization)
- **Opzionale**: Può essere rimosso se images non utilizzate
- **Alternativa**: Potrebbe usare imagemagick invece di vips

### Development Dependencies

```ruby
spec.add_development_dependency "rails", ">= 6.1"
```
- **Uso**: Testing Rails integration
- **Versioni supportate**: Rails 6.1, 7.0, 7.1

```ruby
spec.add_development_dependency "rspec", "~> 3.0"
spec.add_development_dependency "rspec-rails", "~> 6.0"
```
- **Uso**: Test framework
- **Richiesto per**: Tutta la test suite

```ruby
spec.add_development_dependency "rubocop", "~> 1.21"
spec.add_development_dependency "rubocop-rspec", "~> 2.0"
spec.add_development_dependency "rubocop-rails", "~> 2.0"
```
- **Uso**: Code quality, linting
- **Richiesto per**: CI/CD quality checks

```ruby
spec.add_development_dependency "simplecov", "~> 0.22"
```
- **Uso**: Code coverage reporting
- **Richiesto per**: Test coverage metrics

```ruby
spec.add_development_dependency "factory_bot_rails", "~> 6.0"
```
- **Uso**: Test fixtures
- **Richiesto per**: Testing con modelli Rails

```ruby
spec.add_development_dependency "webmock", "~> 3.0"
```
- **Uso**: HTTP mocking per test (ping search engines)
- **Richiesto per**: Step 04 tests (Sitemap ping)

```ruby
spec.add_development_dependency "vcr", "~> 6.0"
```
- **Uso**: Record HTTP interactions
- **Richiesto per**: Integration tests

```ruby
spec.add_development_dependency "pry-byebug", "~> 3.0"
```
- **Uso**: Debugging
- **Opzionale**: Development convenience

```ruby
spec.add_development_dependency "rake", "~> 13.0"
```
- **Uso**: Task runner
- **Richiesto per**: Rake tasks

---

## System Dependencies

### Obbligatorie

**Nessuna** - BetterSeo core funziona senza system dependencies

### Opzionali (per Image Optimization - Step 07)

#### libvips (Raccomandato)

**Installazione**:

```bash
# macOS (Homebrew)
brew install vips

# Ubuntu/Debian
sudo apt-get update
sudo apt-get install libvips-dev

# Fedora/RHEL
sudo yum install vips-devel

# Windows (via scoop)
scoop install vips
```

**Verifica installazione**:
```bash
vips --version
# => vips-8.14.0
```

**Vantaggi**:
- Molto più veloce di ImageMagick (4-5x)
- Memoria usage inferiore
- Migliore qualità WebP
- Built-in threading

#### ImageMagick (Alternativa)

Se libvips non disponibile, fallback su ImageMagick:

```bash
# macOS
brew install imagemagick

# Ubuntu/Debian
sudo apt-get install imagemagick libmagickwand-dev

# Fedora/RHEL
sudo yum install ImageMagick ImageMagick-devel
```

**Verifica**:
```bash
convert --version
# => Version: ImageMagick 7.1.0
```

**Gem alternative**:
```ruby
# Se usi ImageMagick invece di vips
spec.add_dependency "mini_magick", "~> 4.11"  # invece di ruby-vips
```

---

## Rails Compatibility Matrix

| BetterSeo | Rails 6.1 | Rails 7.0 | Rails 7.1 | Ruby 3.0 | Ruby 3.1 | Ruby 3.2 | Ruby 3.3 |
|-----------|-----------|-----------|-----------|----------|----------|----------|----------|
| 0.1.0     | ✅        | ✅        | ✅        | ✅       | ✅       | ✅       | ✅       |
| 0.2.0+    | ✅        | ✅        | ✅        | ✅       | ✅       | ✅       | ✅       |
| 1.0.0     | ✅        | ✅        | ✅        | ✅       | ✅       | ✅       | ✅       |

**Note**:
- Rails 6.0 e precedenti: non supportati
- Ruby < 3.0: non supportato
- ActiveSupport standalone (senza Rails): supportato

---

## Installazione Completa

### Setup Development Environment

```bash
# 1. Clone repository
git clone https://github.com/alessiobussolari/better_seo.git
cd better_seo

# 2. Install Ruby dependencies
bundle install

# 3. (Opzionale) Install libvips per images
brew install vips  # macOS
# oppure
sudo apt-get install libvips-dev  # Ubuntu

# 4. Setup test database (se necessario)
bundle exec rake db:test:prepare

# 5. Run tests
bundle exec rspec

# 6. Run linter
bundle exec rubocop
```

---

## Troubleshooting

### Error: `ruby-vips` gem non compila

**Problema**: libvips non trovato

**Soluzione**:
```bash
# macOS
brew install vips pkg-config

# Ubuntu
sudo apt-get install libvips-dev pkg-config

# Reinstall gem
gem uninstall ruby-vips
bundle install
```

### Error: ActiveSupport version conflict

**Problema**: Conflitto versione Rails/ActiveSupport

**Soluzione**:
```bash
# Update bundle
bundle update activesupport

# Oppure specifica versione Rails nel Gemfile.lock
bundle install --conservative
```

### Warning: SimpleCov non genera coverage

**Problema**: simplecov non carica

**Soluzione**:
```ruby
# spec/spec_helper.rb - deve essere PRIMO require
require 'simplecov'
SimpleCov.start 'rails'

require 'better_seo'
# ... altri requires
```

---

## Gem Opzionali per Produzione

### Per Performance

```ruby
gem "oj"  # Fast JSON parsing
```
- Uso: JSON-LD generation più veloce
- Speedup: ~2x su structured data

### Per Caching

```ruby
gem "redis"  # Per cache sitemap/robots
gem "redis-rails"  # Rails cache backend
```
- Uso: Cache sitemap generation
- Beneficio: Sitemap >10k URLs molto più veloce

### Per Cloud Storage

```ruby
gem "aws-sdk-s3"  # Amazon S3
gem "google-cloud-storage"  # Google Cloud
gem "azure-storage-blob"  # Microsoft Azure
```
- Uso: Upload immagini ottimizzate su cloud
- Opzionale: Solo se usi cloud storage

---

## CI/CD Dependencies

### GitHub Actions

```yaml
# .github/workflows/ci.yml
- uses: ruby/setup-ruby@v1
  with:
    ruby-version: 3.3
    bundler-cache: true

# Installa libvips per image tests
- name: Install libvips
  run: sudo apt-get install libvips-dev
```

### CircleCI

```yaml
# .circleci/config.yml
- run:
    name: Install libvips
    command: |
      sudo apt-get update
      sudo apt-get install libvips-dev
```

---

## Minimal vs Full Installation

### Minimal (Solo Meta Tags e SEO base)

```ruby
# Gemfile
gem "better_seo"

# No system dependencies required
```

**Funzionalità disponibili**:
- ✅ Meta tags
- ✅ Open Graph
- ✅ Twitter Cards
- ✅ Structured Data
- ✅ Sitemap
- ✅ Robots.txt
- ❌ Image optimization (non disponibile)

### Full (Con Image Optimization)

```ruby
# Gemfile
gem "better_seo"

# System: libvips installato
```

**Funzionalità disponibili**:
- ✅ Tutte le features minimal
- ✅ Image optimization
- ✅ WebP conversion
- ✅ Responsive images
- ✅ Lazy loading

---

## Verifica Dipendenze

```bash
# Check gem dependencies
bundle list

# Check for security vulnerabilities
bundle audit

# Check for outdated gems
bundle outdated

# Verifica libvips (se installato)
ruby -e "require 'vips'; puts Vips::version_string"
```

---

**Ultima modifica**: 2025-10-22
