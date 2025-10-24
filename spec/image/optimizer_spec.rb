# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::Image::Optimizer do
  let(:test_image_dir) { "/tmp/better_seo_test_images_#{Time.now.to_i}" }
  let(:sample_image) { File.join(test_image_dir, "sample.jpg") }

  before(:all) do
    # Check if ImageMagick is available

    require "mini_magick"
    @imagemagick_available = MiniMagick::Tool::Identify.new.version.present?
  rescue StandardError
    @imagemagick_available = false
  end

  before do
    FileUtils.mkdir_p(test_image_dir)
    # Create a simple test image if ImageMagick is available
    if @imagemagick_available
      MiniMagick::Tool::Convert.new do |convert|
        convert << "xc:red"
        convert.merge! ["-resize", "800x600"]
        convert << sample_image
      end
    end
  end

  after do
    FileUtils.rm_rf(test_image_dir)
  end

  describe "#initialize" do
    it "creates optimizer with default options" do
      optimizer = described_class.new
      expect(optimizer.quality).to eq(85)
    end

    it "creates optimizer with custom quality" do
      optimizer = described_class.new(quality: 75)
      expect(optimizer.quality).to eq(75)
    end
  end

  describe "#validate_format!" do
    it "accepts valid image formats" do
      optimizer = described_class.new

      expect { optimizer.validate_format!("image.jpg") }.not_to raise_error
      expect { optimizer.validate_format!("image.jpeg") }.not_to raise_error
      expect { optimizer.validate_format!("image.png") }.not_to raise_error
      expect { optimizer.validate_format!("image.webp") }.not_to raise_error
      expect { optimizer.validate_format!("image.gif") }.not_to raise_error
    end

    it "raises error for invalid formats" do
      optimizer = described_class.new

      expect { optimizer.validate_format!("document.pdf") }.to raise_error(BetterSeo::ImageError, /Unsupported format/)
      expect { optimizer.validate_format!("video.mp4") }.to raise_error(BetterSeo::ImageError)
      expect { optimizer.validate_format!("file.txt") }.to raise_error(BetterSeo::ImageError)
    end

    it "is case insensitive" do
      optimizer = described_class.new

      expect { optimizer.validate_format!("image.JPG") }.not_to raise_error
      expect { optimizer.validate_format!("image.PNG") }.not_to raise_error
    end
  end

  describe "#convert_to_webp", if: @imagemagick_available do
    it "converts JPEG to WebP" do
      optimizer = described_class.new
      output = File.join(test_image_dir, "output.webp")

      optimizer.convert_to_webp(sample_image, output)

      expect(File.exist?(output)).to be true
      expect(File.extname(output)).to eq(".webp")
    end

    it "maintains quality setting" do
      optimizer = described_class.new(quality: 90)
      output = File.join(test_image_dir, "high_quality.webp")

      optimizer.convert_to_webp(sample_image, output)

      expect(File.exist?(output)).to be true
    end

    it "raises error for non-existent source" do
      optimizer = described_class.new
      expect do
        optimizer.convert_to_webp("/nonexistent/image.jpg", "/tmp/output.webp")
      end.to raise_error(BetterSeo::ImageError)
    end
  end

  describe "#resize", if: @imagemagick_available do
    it "resizes image to specified dimensions" do
      optimizer = described_class.new
      output = File.join(test_image_dir, "resized.jpg")

      optimizer.resize(sample_image, output, width: 400, height: 300)

      expect(File.exist?(output)).to be true

      image = MiniMagick::Image.open(output)
      expect(image.width).to eq(400)
      expect(image.height).to eq(300)
    end

    it "resizes with width only" do
      optimizer = described_class.new
      output = File.join(test_image_dir, "resized_width.jpg")

      optimizer.resize(sample_image, output, width: 400)

      expect(File.exist?(output)).to be true
      image = MiniMagick::Image.open(output)
      expect(image.width).to eq(400)
    end

    it "resizes with height only" do
      optimizer = described_class.new
      output = File.join(test_image_dir, "resized_height.jpg")

      optimizer.resize(sample_image, output, height: 300)

      expect(File.exist?(output)).to be true
      image = MiniMagick::Image.open(output)
      expect(image.height).to eq(300)
    end
  end

  describe "#compress", if: @imagemagick_available do
    it "compresses image with default quality" do
      optimizer = described_class.new
      output = File.join(test_image_dir, "compressed.jpg")

      original_size = File.size(sample_image)
      optimizer.compress(sample_image, output)

      expect(File.exist?(output)).to be true
      compressed_size = File.size(output)
      expect(compressed_size).to be <= original_size
    end

    it "compresses with custom quality" do
      optimizer = described_class.new(quality: 50)
      output = File.join(test_image_dir, "low_quality.jpg")

      optimizer.compress(sample_image, output)

      expect(File.exist?(output)).to be true
    end
  end

  describe "#generate_responsive", if: @imagemagick_available do
    it "generates multiple sizes" do
      optimizer = described_class.new
      sizes = { small: 320, medium: 768, large: 1024 }

      results = optimizer.generate_responsive(sample_image, test_image_dir, sizes: sizes)

      expect(results.size).to eq(3)
      expect(File.exist?(results[:small])).to be true
      expect(File.exist?(results[:medium])).to be true
      expect(File.exist?(results[:large])).to be true
    end

    it "generates with custom prefix" do
      optimizer = described_class.new
      sizes = { thumb: 150 }

      results = optimizer.generate_responsive(sample_image, test_image_dir, sizes: sizes, prefix: "custom")

      expect(results[:thumb]).to include("custom")
      expect(File.exist?(results[:thumb])).to be true
    end
  end

  describe "#optimize", if: @imagemagick_available do
    it "optimizes image with all operations" do
      optimizer = described_class.new
      output = File.join(test_image_dir, "optimized.jpg")

      result = optimizer.optimize(sample_image, output, resize: { width: 600 })

      expect(File.exist?(output)).to be true
      expect(result[:original_size]).to be > 0
      expect(result[:optimized_size]).to be > 0
      expect(result[:reduction_percent]).to be_a(Numeric)
    end

    it "returns optimization statistics" do
      optimizer = described_class.new
      output = File.join(test_image_dir, "optimized.jpg")

      result = optimizer.optimize(sample_image, output)

      expect(result).to have_key(:original_size)
      expect(result).to have_key(:optimized_size)
      expect(result).to have_key(:reduction_percent)
    end
  end
end
