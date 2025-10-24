# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::DSL::TwitterCards do
  subject(:twitter) { described_class.new }

  describe "#initialize" do
    it "inherits from Base" do
      expect(twitter).to be_a(BetterSeo::DSL::Base)
    end

    it "starts with empty config" do
      expect(twitter.config).to eq({})
    end
  end

  describe "#card" do
    it "sets and gets card type" do
      twitter.card("summary_large_image")
      expect(twitter.card).to eq("summary_large_image")
    end

    it "defaults to summary_large_image if not set" do
      expect(twitter.card).to be_nil
    end

    it "returns self for chaining" do
      expect(twitter.card("summary")).to eq(twitter)
    end

    it "accepts valid card types" do
      %w[summary summary_large_image app player].each do |type|
        twitter.card(type)
        expect(twitter.card).to eq(type)
      end
    end
  end

  describe "#site" do
    it "sets and gets site handle" do
      twitter.site("@mysite")
      expect(twitter.site).to eq("@mysite")
    end

    it "adds @ prefix if missing" do
      twitter.site("mysite")
      expect(twitter.site).to eq("@mysite")
    end

    it "does not double @ prefix" do
      twitter.site("@mysite")
      expect(twitter.site).to eq("@mysite")
    end

    it "returns self for chaining" do
      expect(twitter.site("@site")).to eq(twitter)
    end
  end

  describe "#creator" do
    it "sets and gets creator handle" do
      twitter.creator("@author")
      expect(twitter.creator).to eq("@author")
    end

    it "adds @ prefix if missing" do
      twitter.creator("author")
      expect(twitter.creator).to eq("@author")
    end

    it "does not double @ prefix" do
      twitter.creator("@author")
      expect(twitter.creator).to eq("@author")
    end
  end

  describe "#title" do
    it "sets and gets title" do
      twitter.title("My Twitter Title")
      expect(twitter.title).to eq("My Twitter Title")
    end

    it "returns nil if not set" do
      expect(twitter.title).to be_nil
    end
  end

  describe "#description" do
    it "sets and gets description" do
      twitter.description("My Twitter Description")
      expect(twitter.description).to eq("My Twitter Description")
    end
  end

  describe "#image" do
    it "sets and gets image URL" do
      twitter.image("https://example.com/image.jpg")
      expect(twitter.image).to eq("https://example.com/image.jpg")
    end

    it "accepts image as hash with url" do
      twitter.image(url: "https://example.com/image.jpg", alt: "Image description")
      expect(twitter.get(:image)).to eq({
        url: "https://example.com/image.jpg",
        alt: "Image description"
      })
    end
  end

  describe "#image_alt" do
    it "sets and gets image alt text" do
      twitter.image_alt("Description of the image")
      expect(twitter.image_alt).to eq("Description of the image")
    end
  end

  describe "player card properties" do
    describe "#player" do
      it "sets player URL" do
        twitter.player("https://example.com/player.html")
        expect(twitter.player).to eq("https://example.com/player.html")
      end
    end

    describe "#player_width" do
      it "sets player width" do
        twitter.player_width(1280)
        expect(twitter.player_width).to eq(1280)
      end
    end

    describe "#player_height" do
      it "sets player height" do
        twitter.player_height(720)
        expect(twitter.player_height).to eq(720)
      end
    end

    describe "#player_stream" do
      it "sets player stream URL" do
        twitter.player_stream("https://example.com/stream.mp4")
        expect(twitter.player_stream).to eq("https://example.com/stream.mp4")
      end
    end
  end

  describe "app card properties" do
    describe "#app_name" do
      it "sets app name for all platforms" do
        twitter.app_name("My App")
        expect(twitter.get(:app_name)).to eq({
          iphone: "My App",
          ipad: "My App",
          googleplay: "My App"
        })
      end

      it "sets app name for specific platform" do
        twitter.app_name("iPhone App", platform: :iphone)
        expect(twitter.get(:app_name)).to eq({ iphone: "iPhone App" })
      end
    end

    describe "#app_id" do
      it "sets app ID for specific platform" do
        twitter.app_id("123456", platform: :iphone)
        expect(twitter.get(:app_id)).to eq({ iphone: "123456" })
      end

      it "sets app ID for googleplay" do
        twitter.app_id("com.example.app", platform: :googleplay)
        expect(twitter.get(:app_id)).to eq({ googleplay: "com.example.app" })
      end
    end

    describe "#app_url" do
      it "sets app URL for specific platform" do
        twitter.app_url("myapp://action", platform: :iphone)
        expect(twitter.get(:app_url)).to eq({ iphone: "myapp://action" })
      end
    end
  end

  describe "#build" do
    it "returns complete configuration" do
      twitter.evaluate do
        card "summary_large_image"
        site "@mysite"
        creator "@author"
        title "Twitter Card Title"
        description "Twitter Card Description"
        image "https://example.com/image.jpg"
        image_alt "Image description"
      end

      result = twitter.build

      expect(result[:card]).to eq("summary_large_image")
      expect(result[:site]).to eq("@mysite")
      expect(result[:creator]).to eq("@author")
      expect(result[:title]).to eq("Twitter Card Title")
      expect(result[:description]).to eq("Twitter Card Description")
      expect(result[:image]).to eq("https://example.com/image.jpg")
      expect(result[:image_alt]).to eq("Image description")
    end
  end

  describe "#validate!" do
    context "with valid data" do
      it "does not raise error with required fields for summary card" do
        twitter.card("summary")
        twitter.title("Title")
        twitter.description("Description")

        expect { twitter.send(:validate!) }.not_to raise_error
      end

      it "does not raise error with required fields for summary_large_image" do
        twitter.card("summary_large_image")
        twitter.title("Title")
        twitter.description("Description")
        twitter.image("https://example.com/image.jpg")

        expect { twitter.send(:validate!) }.not_to raise_error
      end
    end

    context "with invalid data" do
      it "raises error when card type is invalid" do
        twitter.card("invalid_type")

        expect {
          twitter.send(:validate!)
        }.to raise_error(BetterSeo::ValidationError, /Invalid card type/)
      end

      it "raises error when title is missing" do
        twitter.card("summary")
        twitter.description("Description")

        expect {
          twitter.send(:validate!)
        }.to raise_error(BetterSeo::ValidationError, /title is required/)
      end

      it "raises error when description is missing" do
        twitter.card("summary")
        twitter.title("Title")

        expect {
          twitter.send(:validate!)
        }.to raise_error(BetterSeo::ValidationError, /description is required/)
      end

      it "raises error when image is missing for summary_large_image" do
        twitter.card("summary_large_image")
        twitter.title("Title")
        twitter.description("Description")

        expect {
          twitter.send(:validate!)
        }.to raise_error(BetterSeo::ValidationError, /image is required/)
      end

      it "raises error when title is too long" do
        twitter.card("summary")
        twitter.title("A" * 80)
        twitter.description("Description")

        expect {
          twitter.send(:validate!)
        }.to raise_error(BetterSeo::ValidationError, /Title too long/)
      end

      it "raises error when description is too long" do
        twitter.card("summary")
        twitter.title("Title")
        twitter.description("A" * 250)

        expect {
          twitter.send(:validate!)
        }.to raise_error(BetterSeo::ValidationError, /Description too long/)
      end
    end
  end

  describe "method chaining" do
    it "supports fluent interface" do
      result = twitter
        .card("summary_large_image")
        .site("@mysite")
        .creator("@author")
        .title("Chained Title")
        .description("Chained Description")
        .image("https://example.com/chain.jpg")
        .image_alt("Chain image")

      expect(result).to eq(twitter)
      expect(twitter.card).to eq("summary_large_image")
      expect(twitter.site).to eq("@mysite")
      expect(twitter.creator).to eq("@author")
      expect(twitter.title).to eq("Chained Title")
    end
  end
end
