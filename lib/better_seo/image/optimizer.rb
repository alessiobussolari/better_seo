# frozen_string_literal: true

begin
  require "mini_magick"
rescue LoadError
  # mini_magick is optional
end

module BetterSeo
  module Image
    class Optimizer
      SUPPORTED_FORMATS = %w[jpg jpeg png webp gif].freeze

      attr_reader :quality

      def initialize(quality: 85)
        @quality = quality
        check_imagemagick!
      end

      # Validate image format
      def validate_format!(path)
        ext = File.extname(path).downcase.delete(".")
        unless SUPPORTED_FORMATS.include?(ext)
          raise ImageError, "Unsupported format: #{ext}. Supported: #{SUPPORTED_FORMATS.join(", ")}"
        end
        true
      end

      # Convert image to WebP
      def convert_to_webp(source, destination)
        check_imagemagick!
        validate_source!(source)

        image = MiniMagick::Image.open(source)
        image.format "webp"
        image.quality @quality
        image.write destination

        destination
      rescue MiniMagick::Error => e
        raise ImageError, "Failed to convert to WebP: #{e.message}"
      end

      # Resize image
      def resize(source, destination, width: nil, height: nil)
        check_imagemagick!
        validate_source!(source)

        raise ImageError, "Either width or height must be specified" if width.nil? && height.nil?

        image = MiniMagick::Image.open(source)

        if width && height
          image.resize "#{width}x#{height}!"
        elsif width
          image.resize "#{width}x"
        else
          image.resize "x#{height}"
        end

        image.write destination

        destination
      rescue MiniMagick::Error => e
        raise ImageError, "Failed to resize: #{e.message}"
      end

      # Compress image
      def compress(source, destination)
        check_imagemagick!
        validate_source!(source)

        image = MiniMagick::Image.open(source)
        image.quality @quality
        image.write destination

        destination
      rescue MiniMagick::Error => e
        raise ImageError, "Failed to compress: #{e.message}"
      end

      # Generate responsive image sizes
      def generate_responsive(source, output_dir, sizes: {}, prefix: "responsive")
        check_imagemagick!
        validate_source!(source)

        FileUtils.mkdir_p(output_dir) unless File.directory?(output_dir)

        results = {}
        ext = File.extname(source)

        sizes.each do |name, width|
          output_path = File.join(output_dir, "#{prefix}_#{name}_#{width}w#{ext}")
          resize(source, output_path, width: width)
          results[name] = output_path
        end

        results
      rescue MiniMagick::Error => e
        raise ImageError, "Failed to generate responsive images: #{e.message}"
      end

      # Optimize image (resize + compress)
      def optimize(source, destination, resize: nil)
        check_imagemagick!
        validate_source!(source)

        original_size = File.size(source)

        if resize
          resize(source, destination, **resize)
        else
          compress(source, destination)
        end

        optimized_size = File.size(destination)
        reduction = ((original_size - optimized_size).to_f / original_size * 100).round(2)

        {
          original_size: original_size,
          optimized_size: optimized_size,
          reduction_percent: reduction
        }
      rescue MiniMagick::Error => e
        raise ImageError, "Failed to optimize: #{e.message}"
      end

      private

      def check_imagemagick!
        return if defined?(MiniMagick)

        raise ImageError, "ImageMagick is not available. Please install ImageMagick and the mini_magick gem."
      end

      def validate_source!(source)
        raise ImageError, "Source file not found: #{source}" unless File.exist?(source)
        validate_format!(source)
      end
    end
  end
end
