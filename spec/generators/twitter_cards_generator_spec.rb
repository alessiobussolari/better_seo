# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::Generators::TwitterCardsGenerator do
  let(:config) do
    {
      card: "summary_large_image",
      site: "@mysite",
      creator: "@author",
      title: "Twitter Card Title",
      description: "Description for Twitter card",
      image: "https://example.com/twitter-image.jpg",
      image_alt: "Image description for accessibility"
    }
  end

  subject(:generator) { described_class.new(config) }

  describe "#initialize" do
    it "accepts configuration hash" do
      expect(generator.instance_variable_get(:@config)).to eq(config)
    end
  end

  describe "#generate" do
    let(:html) { generator.generate }

    it "returns a string" do
      expect(html).to be_a(String)
    end

    it "generates twitter:card meta tag" do
      expect(html).to include('<meta name="twitter:card" content="summary_large_image">')
    end

    it "generates twitter:site meta tag" do
      expect(html).to include('<meta name="twitter:site" content="@mysite">')
    end

    it "generates twitter:creator meta tag" do
      expect(html).to include('<meta name="twitter:creator" content="@author">')
    end

    it "generates twitter:title meta tag" do
      expect(html).to include('<meta name="twitter:title" content="Twitter Card Title">')
    end

    it "generates twitter:description meta tag" do
      expect(html).to include('<meta name="twitter:description" content="Description for Twitter card">')
    end

    it "generates twitter:image meta tag" do
      expect(html).to include('<meta name="twitter:image" content="https://example.com/twitter-image.jpg">')
    end

    it "generates twitter:image:alt meta tag" do
      expect(html).to include('<meta name="twitter:image:alt" content="Image description for accessibility">')
    end

    it "joins all tags with newlines" do
      lines = html.split("\n")
      expect(lines.length).to be >= 7
    end

    it "does not include tags for missing values" do
      minimal = { card: "summary", title: "Title", description: "Desc" }
      gen = described_class.new(minimal)
      minimal_html = gen.generate

      expect(minimal_html).not_to include("twitter:site")
      expect(minimal_html).not_to include("twitter:image")
    end
  end

  describe "player card properties" do
    let(:player_config) do
      {
        card: "player",
        title: "Video Title",
        description: "Video Description",
        player: "https://example.com/player.html",
        player_width: 1280,
        player_height: 720,
        player_stream: "https://example.com/stream.mp4"
      }
    end

    let(:gen) { described_class.new(player_config) }
    let(:html) { gen.generate }

    it "generates twitter:player meta tag" do
      expect(html).to include('<meta name="twitter:player" content="https://example.com/player.html">')
    end

    it "generates twitter:player:width meta tag" do
      expect(html).to include('<meta name="twitter:player:width" content="1280">')
    end

    it "generates twitter:player:height meta tag" do
      expect(html).to include('<meta name="twitter:player:height" content="720">')
    end

    it "generates twitter:player:stream meta tag" do
      expect(html).to include('<meta name="twitter:player:stream" content="https://example.com/stream.mp4">')
    end
  end

  describe "app card properties" do
    let(:app_config) do
      {
        card: "app",
        title: "App Title",
        description: "App Description",
        app_name: { iphone: "iPhone App", ipad: "iPad App", googleplay: "Android App" },
        app_id: { iphone: "123456", googleplay: "com.example.app" },
        app_url: { iphone: "myapp://action", googleplay: "myapp://action" }
      }
    end

    let(:gen) { described_class.new(app_config) }
    let(:html) { gen.generate }

    it "generates twitter:app:name:iphone meta tag" do
      expect(html).to include('<meta name="twitter:app:name:iphone" content="iPhone App">')
    end

    it "generates twitter:app:name:ipad meta tag" do
      expect(html).to include('<meta name="twitter:app:name:ipad" content="iPad App">')
    end

    it "generates twitter:app:name:googleplay meta tag" do
      expect(html).to include('<meta name="twitter:app:name:googleplay" content="Android App">')
    end

    it "generates twitter:app:id:iphone meta tag" do
      expect(html).to include('<meta name="twitter:app:id:iphone" content="123456">')
    end

    it "generates twitter:app:id:googleplay meta tag" do
      expect(html).to include('<meta name="twitter:app:id:googleplay" content="com.example.app">')
    end

    it "generates twitter:app:url:iphone meta tag" do
      expect(html).to include('<meta name="twitter:app:url:iphone" content="myapp://action">')
    end

    it "generates twitter:app:url:googleplay meta tag" do
      expect(html).to include('<meta name="twitter:app:url:googleplay" content="myapp://action">')
    end
  end

  describe "image hash configuration" do
    context "with image as hash" do
      let(:image_config) do
        {
          card: "summary",
          title: "Title",
          description: "Desc",
          image: { url: "https://example.com/img.jpg", alt: "Alt text" }
        }
      end

      let(:gen) { described_class.new(image_config) }
      let(:html) { gen.generate }

      it "generates twitter:image with URL from hash" do
        expect(html).to include('<meta name="twitter:image" content="https://example.com/img.jpg">')
      end

      it "generates twitter:image:alt from hash" do
        expect(html).to include('<meta name="twitter:image:alt" content="Alt text">')
      end
    end
  end

  describe "HTML escaping" do
    it "escapes special characters in content" do
      gen = described_class.new({
        card: "summary",
        title: 'Title with "quotes" & <tags>',
        description: "Description"
      })
      html = gen.generate
      expect(html).to include("&quot;")
      expect(html).to include("&lt;")
      expect(html).to include("&gt;")
      expect(html).to include("&amp;")
    end
  end

  describe "integration with DSL" do
    it "works with TwitterCards DSL output" do
      twitter = BetterSeo::DSL::TwitterCards.new
      twitter.card("summary_large_image")
      twitter.site("@mysite")
      twitter.creator("@creator")
      twitter.title("DSL Twitter Title")
      twitter.description("DSL Description")
      twitter.image("https://example.com/dsl.jpg")

      gen = described_class.new(twitter.build)
      html = gen.generate

      expect(html).to include("DSL Twitter Title")
      expect(html).to include("@mysite")
      expect(html).to include("@creator")
      expect(html).to include("summary_large_image")
    end
  end
end
