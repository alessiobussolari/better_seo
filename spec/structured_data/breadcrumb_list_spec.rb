# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::StructuredData::BreadcrumbList do
  describe "#initialize" do
    it "creates BreadcrumbList with correct @type" do
      breadcrumb = described_class.new
      expect(breadcrumb.type).to eq("BreadcrumbList")
    end

    it "initializes with empty items array" do
      breadcrumb = described_class.new
      expect(breadcrumb.items).to eq([])
    end
  end

  describe "#add_item" do
    it "adds breadcrumb item with name and url" do
      breadcrumb = described_class.new
      breadcrumb.add_item(name: "Home", url: "https://example.com")

      items = breadcrumb.items
      expect(items.size).to eq(1)
      expect(items[0][:name]).to eq("Home")
      expect(items[0][:url]).to eq("https://example.com")
    end

    it "assigns position automatically starting from 1" do
      breadcrumb = described_class.new
      breadcrumb.add_item(name: "Home", url: "https://example.com")
      breadcrumb.add_item(name: "Products", url: "https://example.com/products")

      items = breadcrumb.items
      expect(items[0][:position]).to eq(1)
      expect(items[1][:position]).to eq(2)
    end

    it "allows manual position override" do
      breadcrumb = described_class.new
      breadcrumb.add_item(name: "Home", url: "https://example.com", position: 1)
      breadcrumb.add_item(name: "Products", url: "https://example.com/products", position: 2)

      items = breadcrumb.items
      expect(items[0][:position]).to eq(1)
      expect(items[1][:position]).to eq(2)
    end

    it "returns self for chaining" do
      breadcrumb = described_class.new
      result = breadcrumb.add_item(name: "Home", url: "https://example.com")
      expect(result).to eq(breadcrumb)
    end

    it "allows chaining multiple add_item calls" do
      breadcrumb = described_class.new
      breadcrumb
        .add_item(name: "Home", url: "https://example.com")
        .add_item(name: "Products", url: "https://example.com/products")
        .add_item(name: "Shoes", url: "https://example.com/products/shoes")

      expect(breadcrumb.items.size).to eq(3)
      expect(breadcrumb.items[0][:name]).to eq("Home")
      expect(breadcrumb.items[1][:name]).to eq("Products")
      expect(breadcrumb.items[2][:name]).to eq("Shoes")
    end
  end

  describe "#add_items" do
    it "adds multiple items from array" do
      breadcrumb = described_class.new
      breadcrumb.add_items([
        { name: "Home", url: "https://example.com" },
        { name: "Products", url: "https://example.com/products" },
        { name: "Shoes", url: "https://example.com/products/shoes" }
      ])

      expect(breadcrumb.items.size).to eq(3)
      expect(breadcrumb.items[0][:position]).to eq(1)
      expect(breadcrumb.items[1][:position]).to eq(2)
      expect(breadcrumb.items[2][:position]).to eq(3)
    end

    it "returns self for chaining" do
      breadcrumb = described_class.new
      result = breadcrumb.add_items([{ name: "Home", url: "https://example.com" }])
      expect(result).to eq(breadcrumb)
    end
  end

  describe "#clear" do
    it "removes all items" do
      breadcrumb = described_class.new
      breadcrumb.add_item(name: "Home", url: "https://example.com")
      breadcrumb.add_item(name: "Products", url: "https://example.com/products")

      breadcrumb.clear
      expect(breadcrumb.items).to be_empty
    end

    it "returns self for chaining" do
      breadcrumb = described_class.new
      result = breadcrumb.clear
      expect(result).to eq(breadcrumb)
    end
  end

  describe "#to_h" do
    it "generates BreadcrumbList schema" do
      breadcrumb = described_class.new
      breadcrumb.add_item(name: "Home", url: "https://example.com")
      breadcrumb.add_item(name: "Products", url: "https://example.com/products")

      hash = breadcrumb.to_h

      expect(hash["@context"]).to eq("https://schema.org")
      expect(hash["@type"]).to eq("BreadcrumbList")
      expect(hash["itemListElement"]).to be_a(Array)
      expect(hash["itemListElement"].size).to eq(2)
    end

    it "generates correct ListItem structure" do
      breadcrumb = described_class.new
      breadcrumb.add_item(name: "Home", url: "https://example.com")

      hash = breadcrumb.to_h
      item = hash["itemListElement"][0]

      expect(item["@type"]).to eq("ListItem")
      expect(item["position"]).to eq(1)
      expect(item["name"]).to eq("Home")
      expect(item["item"]).to eq("https://example.com")
    end

    it "handles all items with correct positions" do
      breadcrumb = described_class.new
      breadcrumb
        .add_item(name: "Home", url: "https://example.com")
        .add_item(name: "Category", url: "https://example.com/category")
        .add_item(name: "Subcategory", url: "https://example.com/category/sub")
        .add_item(name: "Product", url: "https://example.com/category/sub/product")

      hash = breadcrumb.to_h
      items = hash["itemListElement"]

      expect(items.size).to eq(4)
      expect(items[0]["position"]).to eq(1)
      expect(items[1]["position"]).to eq(2)
      expect(items[2]["position"]).to eq(3)
      expect(items[3]["position"]).to eq(4)
      expect(items[3]["name"]).to eq("Product")
    end
  end

  describe "#to_script_tag" do
    it "generates valid JSON-LD script tag" do
      breadcrumb = described_class.new
      breadcrumb.add_item(name: "Home", url: "https://example.com")
      breadcrumb.add_item(name: "Products", url: "https://example.com/products")

      tag = breadcrumb.to_script_tag

      expect(tag).to include('<script type="application/ld+json">')
      expect(tag).to include('"@type": "BreadcrumbList"')
      expect(tag).to include('"name": "Home"')
      expect(tag).to include('</script>')
    end
  end

  describe "complete example" do
    it "generates comprehensive breadcrumb markup" do
      breadcrumb = described_class.new
      breadcrumb
        .add_item(name: "Home", url: "https://example.com")
        .add_item(name: "Electronics", url: "https://example.com/electronics")
        .add_item(name: "Computers", url: "https://example.com/electronics/computers")
        .add_item(name: "Laptops", url: "https://example.com/electronics/computers/laptops")
        .add_item(name: "Gaming Laptops", url: "https://example.com/electronics/computers/laptops/gaming")

      hash = breadcrumb.to_h

      expect(hash["@type"]).to eq("BreadcrumbList")
      expect(hash["itemListElement"].size).to eq(5)

      items = hash["itemListElement"]
      expect(items[0]["name"]).to eq("Home")
      expect(items[0]["item"]).to eq("https://example.com")
      expect(items[0]["position"]).to eq(1)

      expect(items[4]["name"]).to eq("Gaming Laptops")
      expect(items[4]["item"]).to eq("https://example.com/electronics/computers/laptops/gaming")
      expect(items[4]["position"]).to eq(5)
    end
  end

  describe "Rails integration example" do
    it "works with Rails path helpers" do
      breadcrumb = described_class.new

      # Simulate Rails path helpers
      root_path = "https://example.com"
      products_path = "https://example.com/products"
      product_path = "https://example.com/products/123"

      breadcrumb
        .add_item(name: "Home", url: root_path)
        .add_item(name: "Products", url: products_path)
        .add_item(name: "Product Detail", url: product_path)

      hash = breadcrumb.to_h
      items = hash["itemListElement"]

      expect(items.size).to eq(3)
      expect(items[0]["item"]).to eq(root_path)
      expect(items[1]["item"]).to eq(products_path)
      expect(items[2]["item"]).to eq(product_path)
    end
  end
end
