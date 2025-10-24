# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::Generators::BreadcrumbsGenerator do
  describe "#initialize" do
    it "creates generator with empty items" do
      generator = described_class.new
      expect(generator.items).to eq([])
    end
  end

  describe "#add_item" do
    it "adds single breadcrumb item" do
      generator = described_class.new
      generator.add_item("Home", "/")

      expect(generator.items.size).to eq(1)
      expect(generator.items.first[:name]).to eq("Home")
      expect(generator.items.first[:url]).to eq("/")
    end

    it "adds multiple breadcrumb items" do
      generator = described_class.new
      generator.add_item("Home", "/")
      generator.add_item("Products", "/products")
      generator.add_item("Laptops", "/products/laptops")

      expect(generator.items.size).to eq(3)
    end

    it "supports method chaining" do
      generator = described_class.new
      result = generator.add_item("Home", "/")

      expect(result).to eq(generator)
    end

    it "handles items without URLs (current page)" do
      generator = described_class.new
      generator.add_item("Home", "/")
      generator.add_item("Current Page", nil)

      expect(generator.items.last[:url]).to be_nil
    end
  end

  describe "#add_items" do
    it "adds multiple items from array" do
      generator = described_class.new
      generator.add_items([
        { name: "Home", url: "/" },
        { name: "Products", url: "/products" },
        { name: "Laptops", url: "/products/laptops" }
      ])

      expect(generator.items.size).to eq(3)
    end

    it "supports method chaining" do
      generator = described_class.new
      result = generator.add_items([{ name: "Home", url: "/" }])

      expect(result).to eq(generator)
    end
  end

  describe "#clear" do
    it "removes all items" do
      generator = described_class.new
      generator.add_item("Home", "/")
      generator.add_item("Products", "/products")
      generator.clear

      expect(generator.items).to eq([])
    end
  end

  describe "#to_html" do
    it "generates basic breadcrumb HTML" do
      generator = described_class.new
      generator.add_item("Home", "/")
      generator.add_item("Products", "/products")

      html = generator.to_html

      expect(html).to include('<nav class="breadcrumb" aria-label="breadcrumb">')
      expect(html).to include('<ol class="breadcrumb">')
      expect(html).to include('<a href="/">Home</a>')
      expect(html).to include('<a href="/products">Products</a>')
    end

    it "marks current page without link" do
      generator = described_class.new
      generator.add_item("Home", "/")
      generator.add_item("Current Page", nil)

      html = generator.to_html

      expect(html).to include('<li class="breadcrumb-item active" aria-current="page">')
      expect(html).to include('Current Page')
      expect(html).not_to include('<a href="">Current Page</a>')
    end

    it "escapes HTML entities in names" do
      generator = described_class.new
      generator.add_item("Home & Garden", "/home-garden")
      generator.add_item("Products < $100", "/cheap-products")

      html = generator.to_html

      expect(html).to include("Home &amp; Garden")
      expect(html).to include("Products &lt; $100")
    end

    it "escapes HTML entities in URLs" do
      generator = described_class.new
      generator.add_item("Search", "/search?q=test&category=books")

      html = generator.to_html

      expect(html).to include('href="/search?q=test&amp;category=books"')
    end

    it "generates schema.org structured data" do
      generator = described_class.new
      generator.add_item("Home", "/")
      generator.add_item("Products", "/products")
      generator.add_item("Laptops", nil)

      html = generator.to_html(schema: true)

      expect(html).to include('itemscope itemtype="https://schema.org/BreadcrumbList"')
      expect(html).to include('itemprop="itemListElement"')
      expect(html).to include('itemtype="https://schema.org/ListItem"')
      expect(html).to include('itemprop="position"')
    end

    it "handles custom CSS classes" do
      generator = described_class.new
      generator.add_item("Home", "/")

      html = generator.to_html(nav_class: "my-breadcrumb-nav", list_class: "my-breadcrumb-list")

      expect(html).to include('<nav class="my-breadcrumb-nav"')
      expect(html).to include('<ol class="my-breadcrumb-list"')
    end

    it "generates empty HTML when no items" do
      generator = described_class.new
      html = generator.to_html

      expect(html).to eq("")
    end
  end

  describe "#to_json_ld" do
    it "generates JSON-LD structured data" do
      generator = described_class.new
      generator.add_item("Home", "https://example.com/")
      generator.add_item("Products", "https://example.com/products")
      generator.add_item("Laptops", "https://example.com/products/laptops")

      json_ld = generator.to_json_ld
      data = JSON.parse(json_ld)

      expect(data["@context"]).to eq("https://schema.org")
      expect(data["@type"]).to eq("BreadcrumbList")
      expect(data["itemListElement"].size).to eq(3)
      expect(data["itemListElement"][0]["@type"]).to eq("ListItem")
      expect(data["itemListElement"][0]["position"]).to eq(1)
      expect(data["itemListElement"][0]["name"]).to eq("Home")
      expect(data["itemListElement"][0]["item"]).to eq("https://example.com/")
    end

    it "handles items without URLs in JSON-LD" do
      generator = described_class.new
      generator.add_item("Home", "https://example.com/")
      generator.add_item("Current Page", nil)

      json_ld = generator.to_json_ld
      data = JSON.parse(json_ld)

      expect(data["itemListElement"][1]["name"]).to eq("Current Page")
      expect(data["itemListElement"][1].key?("item")).to be false
    end

    it "returns empty string when no items" do
      generator = described_class.new
      json_ld = generator.to_json_ld

      expect(json_ld).to eq("")
    end
  end

  describe "#to_script_tag" do
    it "wraps JSON-LD in script tag" do
      generator = described_class.new
      generator.add_item("Home", "https://example.com/")

      script = generator.to_script_tag

      expect(script).to include('<script type="application/ld+json">')
      expect(script).to include('"@context":"https://schema.org"')
      expect(script).to include('</script>')
    end

    it "returns empty string when no items" do
      generator = described_class.new
      script = generator.to_script_tag

      expect(script).to eq("")
    end
  end

  describe "integration with Rails" do
    it "generates complete breadcrumb with HTML and structured data" do
      generator = described_class.new
      generator.add_item("Home", "https://example.com/")
      generator.add_item("Blog", "https://example.com/blog")
      generator.add_item("Ruby on Rails", nil)

      html = generator.to_html(schema: true)
      script = generator.to_script_tag

      expect(html).to include("Home")
      expect(html).to include("Blog")
      expect(html).to include("Ruby on Rails")
      expect(script).to include('"@type":"BreadcrumbList"')
    end
  end
end
