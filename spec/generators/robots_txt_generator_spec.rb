# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::Generators::RobotsTxtGenerator do
  describe "#initialize" do
    it "creates generator with empty rules" do
      generator = described_class.new
      expect(generator.rules).to eq([])
      expect(generator.sitemaps).to eq([])
    end
  end

  describe "#add_rule" do
    it "adds rule for specific user agent" do
      generator = described_class.new
      generator.add_rule("Googlebot", disallow: "/admin")

      expect(generator.rules.size).to eq(1)
      expect(generator.rules.first[:user_agent]).to eq("Googlebot")
      expect(generator.rules.first[:disallow]).to eq(["/admin"])
    end

    it "adds multiple disallow paths" do
      generator = described_class.new
      generator.add_rule("*", disallow: ["/admin", "/private", "/tmp"])

      expect(generator.rules.first[:disallow]).to eq(["/admin", "/private", "/tmp"])
    end

    it "adds allow paths" do
      generator = described_class.new
      generator.add_rule("*", allow: "/public", disallow: "/admin")

      expect(generator.rules.first[:allow]).to eq(["/public"])
      expect(generator.rules.first[:disallow]).to eq(["/admin"])
    end

    it "supports method chaining" do
      generator = described_class.new
      result = generator.add_rule("*", disallow: "/admin")

      expect(result).to eq(generator)
    end

    it "handles multiple rules for different user agents" do
      generator = described_class.new
      generator.add_rule("Googlebot", disallow: "/admin")
      generator.add_rule("Bingbot", disallow: "/temp")
      generator.add_rule("*", disallow: "/private")

      expect(generator.rules.size).to eq(3)
    end
  end

  describe "#set_crawl_delay" do
    it "sets crawl delay for user agent" do
      generator = described_class.new
      generator.add_rule("Bingbot", disallow: "/admin")
      generator.set_crawl_delay("Bingbot", 2)

      rule = generator.rules.find { |r| r[:user_agent] == "Bingbot" }
      expect(rule[:crawl_delay]).to eq(2)
    end

    it "supports method chaining" do
      generator = described_class.new
      generator.add_rule("*", disallow: "/admin")
      result = generator.set_crawl_delay("*", 1)

      expect(result).to eq(generator)
    end

    it "creates rule if user agent not found" do
      generator = described_class.new
      generator.set_crawl_delay("Googlebot", 5)

      rule = generator.rules.find { |r| r[:user_agent] == "Googlebot" }
      expect(rule).not_to be_nil
      expect(rule[:crawl_delay]).to eq(5)
    end
  end

  describe "#add_sitemap" do
    it "adds sitemap URL" do
      generator = described_class.new
      generator.add_sitemap("https://example.com/sitemap.xml")

      expect(generator.sitemaps).to eq(["https://example.com/sitemap.xml"])
    end

    it "adds multiple sitemaps" do
      generator = described_class.new
      generator.add_sitemap("https://example.com/sitemap1.xml")
      generator.add_sitemap("https://example.com/sitemap2.xml")

      expect(generator.sitemaps.size).to eq(2)
    end

    it "supports method chaining" do
      generator = described_class.new
      result = generator.add_sitemap("https://example.com/sitemap.xml")

      expect(result).to eq(generator)
    end
  end

  describe "#clear" do
    it "removes all rules and sitemaps" do
      generator = described_class.new
      generator.add_rule("*", disallow: "/admin")
      generator.add_sitemap("https://example.com/sitemap.xml")
      generator.clear

      expect(generator.rules).to eq([])
      expect(generator.sitemaps).to eq([])
    end
  end

  describe "#to_text" do
    it "generates basic robots.txt" do
      generator = described_class.new
      generator.add_rule("*", disallow: "/admin")

      text = generator.to_text

      expect(text).to include("User-agent: *")
      expect(text).to include("Disallow: /admin")
    end

    it "generates robots.txt with multiple user agents" do
      generator = described_class.new
      generator.add_rule("Googlebot", disallow: "/private")
      generator.add_rule("Bingbot", disallow: "/temp")

      text = generator.to_text

      expect(text).to include("User-agent: Googlebot")
      expect(text).to include("Disallow: /private")
      expect(text).to include("User-agent: Bingbot")
      expect(text).to include("Disallow: /temp")
    end

    it "includes allow directives" do
      generator = described_class.new
      generator.add_rule("*", allow: "/public", disallow: "/admin")

      text = generator.to_text

      expect(text).to include("Allow: /public")
      expect(text).to include("Disallow: /admin")
    end

    it "includes crawl delay" do
      generator = described_class.new
      generator.add_rule("Bingbot", disallow: "/admin")
      generator.set_crawl_delay("Bingbot", 2)

      text = generator.to_text

      expect(text).to include("Crawl-delay: 2")
    end

    it "includes sitemap URLs" do
      generator = described_class.new
      generator.add_sitemap("https://example.com/sitemap.xml")
      generator.add_sitemap("https://example.com/sitemap2.xml")

      text = generator.to_text

      expect(text).to include("Sitemap: https://example.com/sitemap.xml")
      expect(text).to include("Sitemap: https://example.com/sitemap2.xml")
    end

    it "separates user agent sections with blank lines" do
      generator = described_class.new
      generator.add_rule("Googlebot", disallow: "/admin")
      generator.add_rule("Bingbot", disallow: "/temp")

      text = generator.to_text

      expect(text).to match(/User-agent: Googlebot.*\n\n.*User-agent: Bingbot/m)
    end

    it "handles multiple disallow paths" do
      generator = described_class.new
      generator.add_rule("*", disallow: ["/admin", "/private", "/tmp"])

      text = generator.to_text

      expect(text).to include("Disallow: /admin")
      expect(text).to include("Disallow: /private")
      expect(text).to include("Disallow: /tmp")
    end

    it "generates empty robots.txt when no rules" do
      generator = described_class.new
      text = generator.to_text

      expect(text).to eq("")
    end
  end

  describe "#write_to_file" do
    it "writes robots.txt to file" do
      generator = described_class.new
      generator.add_rule("*", disallow: "/admin")

      path = "/tmp/robots_test_#{Time.now.to_i}.txt"
      generator.write_to_file(path)

      expect(File.exist?(path)).to be true
      content = File.read(path)
      expect(content).to include("User-agent: *")
      expect(content).to include("Disallow: /admin")

      File.delete(path)
    end

    it "creates parent directory if needed" do
      generator = described_class.new
      generator.add_rule("*", disallow: "/admin")

      dir = "/tmp/better_seo_test_#{Time.now.to_i}"
      path = "#{dir}/robots.txt"
      generator.write_to_file(path)

      expect(File.exist?(path)).to be true

      FileUtils.rm_rf(dir)
    end
  end

  describe "complete example" do
    it "generates comprehensive robots.txt" do
      generator = described_class.new

      # Allow all bots except specific paths
      generator.add_rule("*", allow: "/", disallow: ["/admin", "/api/private"])

      # Specific rules for Googlebot
      generator.add_rule("Googlebot", allow: "/api/public", disallow: "/temp")

      # Crawl delay for aggressive bots
      generator.add_rule("Bingbot", disallow: "/admin")
      generator.set_crawl_delay("Bingbot", 2)

      # Sitemaps
      generator.add_sitemap("https://example.com/sitemap.xml")
      generator.add_sitemap("https://example.com/sitemap_images.xml")

      text = generator.to_text

      expect(text).to include("User-agent: *")
      expect(text).to include("Allow: /")
      expect(text).to include("Disallow: /admin")
      expect(text).to include("User-agent: Googlebot")
      expect(text).to include("User-agent: Bingbot")
      expect(text).to include("Crawl-delay: 2")
      expect(text).to include("Sitemap: https://example.com/sitemap.xml")
      expect(text).to include("Sitemap: https://example.com/sitemap_images.xml")
    end
  end

  describe "Rails integration" do
    it "generates robots.txt for Rails app" do
      generator = described_class.new
      generator.add_rule("*", disallow: ["/admin", "/api/internal"])
      generator.add_sitemap("https://myapp.com/sitemap.xml")

      text = generator.to_text

      expect(text).to be_a(String)
      expect(text).to include("User-agent: *")
      expect(text).to include("Sitemap:")
    end
  end
end
