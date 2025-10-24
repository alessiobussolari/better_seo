# Step 07: Ottimizzazione Immagini e WebP

**Versione Target**: 0.8.0
**Durata Stimata**: 2-3 settimane
**Priorità**: 🟢 BASSA (Nice to have)
**Dipendenze**: Step 01, 05

---

## Obiettivi

1. ✅ Conversione JPEG/PNG → WebP
2. ✅ Resize automatico (varianti multiple)
3. ✅ Compressione intelligente
4. ✅ Helper `seo_image_tag` con lazy loading
5. ✅ Picture tag con fallback
6. ✅ Active Storage/CarrierWave/Shrine integration
7. ✅ Rake tasks batch processing

---

## Dipendenze Esterne

```ruby
# better_seo.gemspec
spec.add_dependency "image_processing", "~> 1.12"  # Wrapper per vips/imagemagick
spec.add_dependency "ruby-vips", "~> 2.1"          # Per WebP e performance
```

**Sistema**: Richiede `libvips` installato

```bash
# macOS
brew install vips

# Ubuntu
apt-get install libvips-dev

# Check installation
vips --version
```

---

## File da Creare

```
lib/better_seo/images/optimizer.rb
lib/better_seo/images/converter.rb
lib/better_seo/images/resizer.rb
lib/better_seo/images/compressor.rb
lib/better_seo/images/validator.rb
lib/better_seo/images/helpers/image_tag_helper.rb
lib/better_seo/tasks/images.rake
```

---

## Implementazione: WebP Converter

```ruby
# lib/better_seo/images/converter.rb
require "image_processing/vips"

module BetterSeo
  module Images
    class Converter
      def self.to_webp(source_path, output_path = nil, quality: 80)
        output_path ||= source_path.sub(/\.(jpe?g|png|gif)$/i, ".webp")

        ImageProcessing::Vips
          .source(source_path)
          .convert("webp")
          .saver(quality: quality)
          .call(destination: output_path)

        output_path
      end
    end
  end
end
```

---

## Implementazione: Image Resizer

```ruby
# lib/better_seo/images/resizer.rb
module BetterSeo
  module Images
    class Resizer
      def initialize(source_path)
        @source_path = source_path
      end

      def generate_variants(sizes_config)
        variants = {}

        sizes_config.each do |size_name, options|
          output_path = variant_path(size_name)

          pipeline = ImageProcessing::Vips.source(@source_path)

          if options[:crop]
            pipeline = pipeline.resize_to_fill(options[:width], options[:height])
          else
            pipeline = pipeline.resize_to_limit(options[:width], options[:height])
          end

          pipeline.call(destination: output_path)
          variants[size_name] = output_path

          # Generate WebP version
          webp_path = Converter.to_webp(output_path)
          variants["#{size_name}_webp".to_sym] = webp_path
        end

        variants
      end

      private

      def variant_path(size_name)
        ext = File.extname(@source_path)
        base = @source_path.sub(ext, "")
        "#{base}-#{size_name}#{ext}"
      end
    end
  end
end
```

---

## Helper: seo_image_tag

```ruby
# lib/better_seo/images/helpers/image_tag_helper.rb
module BetterSeo
  module Images
    module Helpers
      module ImageTagHelper
        def seo_image_tag(source, alt:, sizes: [], webp: true, lazy: false, **options)
          if webp && sizes.any?
            # Generate picture tag with WebP + responsive
            render_picture_tag(source, alt: alt, sizes: sizes, lazy: lazy, **options)
          elsif webp
            # Simple picture tag with WebP fallback
            render_simple_picture_tag(source, alt: alt, lazy: lazy, **options)
          else
            # Standard img tag
            image_tag(source, alt: alt, loading: (lazy ? "lazy" : nil), **options)
          end
        end

        private

        def render_picture_tag(source, alt:, sizes:, lazy:, **options)
          webp_srcset = sizes.map { |s| "#{variant_path(source, s, 'webp')} #{size_width(s)}w" }.join(", ")
          jpg_srcset = sizes.map { |s| "#{variant_path(source, s, 'jpg')} #{size_width(s)}w" }.join(", ")

          content_tag(:picture, class: "seo-image #{'lazy-image' if lazy}") do
            concat tag(:source, type: "image/webp", srcset: webp_srcset)
            concat tag(:source, type: "image/jpeg", srcset: jpg_srcset)
            concat image_tag(source, alt: alt, loading: (lazy ? "lazy" : nil), **options)
          end
        end

        def render_simple_picture_tag(source, alt:, lazy:, **options)
          webp_source = source.sub(/\.(jpe?g|png)$/i, ".webp")

          content_tag(:picture) do
            concat tag(:source, type: "image/webp", srcset: webp_source)
            concat image_tag(source, alt: alt, loading: (lazy ? "lazy" : nil), **options)
          end
        end

        def variant_path(source, size, format)
          ext = File.extname(source)
          base = source.sub(ext, "")
          "#{base}-#{size}.#{format}"
        end

        def size_width(size_name)
          config = BetterSeo.configuration.images.sizes[size_name]
          config&.dig(:width) || 1200
        end
      end
    end
  end
end
```

---

## Rake Tasks

```ruby
# lib/better_seo/tasks/images.rake
namespace :better_seo do
  namespace :images do
    desc "Convert all images to WebP"
    task :convert_to_webp, [:path] => :environment do |t, args|
      path = args[:path] || Rails.root.join("public", "images")

      Dir.glob("#{path}/**/*.{jpg,jpeg,png}").each do |file|
        puts "Converting #{file}..."
        BetterSeo::Images::Converter.to_webp(file)
      end

      puts "✓ WebP conversion completed"
    end

    desc "Generate image variants"
    task :generate_variants, [:path] => :environment do |t, args|
      path = args[:path] || Rails.root.join("public", "images")
      sizes = BetterSeo.configuration.images.sizes

      Dir.glob("#{path}/**/*.{jpg,jpeg,png}").each do |file|
        puts "Generating variants for #{file}..."
        resizer = BetterSeo::Images::Resizer.new(file)
        resizer.generate_variants(sizes.to_h)
      end

      puts "✓ Image variants generated"
    end

    desc "Validate images for SEO"
    task :validate => :environment do
      # Implementation: check alt text, file sizes, etc.
      puts "✓ Image validation completed"
    end
  end
end
```

---

## Checklist

- [ ] WebP converter con ruby-vips
- [ ] Image resizer per varianti
- [ ] Smart compressor (quality optimization)
- [ ] Helper `seo_image_tag`
- [ ] Picture tag con srcset responsive
- [ ] Lazy loading support
- [ ] Blur placeholder (optional)
- [ ] Active Storage integration
- [ ] CarrierWave integration
- [ ] Shrine integration
- [ ] Rake tasks (convert, resize, validate)
- [ ] Image validator (alt text, size, format)
- [ ] Test coverage > 85%
- [ ] Performance benchmarks

---

**Status**: Implementation Ready
**Note**: Richiede libvips system dependency
