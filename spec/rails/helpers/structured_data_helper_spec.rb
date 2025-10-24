# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::Rails::Helpers::StructuredDataHelper do
  let(:helper) do
    Class.new do
      include BetterSeo::Rails::Helpers::StructuredDataHelper

      def raw(content)
        content
      end
    end.new
  end

  describe "#structured_data_tag" do
    it "generates script tag from structured data object" do
      org = BetterSeo::StructuredData::Organization.new
      org.name("Acme Corp")
      org.url("https://acme.com")

      tag = helper.structured_data_tag(org)

      expect(tag).to include('<script type="application/ld+json">')
      expect(tag).to include('"@type": "Organization"')
      expect(tag).to include('"name": "Acme Corp"')
      expect(tag).to include("</script>")
    end

    it "generates script tag from hash configuration" do
      tag = helper.structured_data_tag(:organization,
                                       name: "Acme Corp",
                                       url: "https://acme.com")

      expect(tag).to include('<script type="application/ld+json">')
      expect(tag).to include('"@type": "Organization"')
      expect(tag).to include('"name": "Acme Corp"')
    end

    it "generates script tag with block" do
      tag = helper.structured_data_tag(:organization) do |org|
        org.name("Acme Corp")
        org.url("https://acme.com")
        org.logo("https://acme.com/logo.png")
      end

      expect(tag).to include('"name": "Acme Corp"')
      expect(tag).to include('"url": "https://acme.com"')
      expect(tag).to include('"logo": "https://acme.com/logo.png"')
    end

    it "supports article type" do
      tag = helper.structured_data_tag(:article,
                                       headline: "Test Article",
                                       author: "John Doe")

      expect(tag).to include('"@type": "Article"')
      expect(tag).to include('"headline": "Test Article"')
    end

    it "supports person type" do
      tag = helper.structured_data_tag(:person,
                                       name: "John Doe",
                                       email: "john@example.com")

      expect(tag).to include('"@type": "Person"')
      expect(tag).to include('"name": "John Doe"')
    end

    it "supports product type" do
      tag = helper.structured_data_tag(:product) do |product|
        product.name("iPhone 15")
        product.brand("Apple")
        product.offers(price: 999.99, price_currency: "USD", availability: "InStock")
      end

      expect(tag).to include('"@type": "Product"')
      expect(tag).to include('"name": "iPhone 15"')
      expect(tag).to include('"brand": "Apple"')
    end

    it "supports breadcrumb_list type" do
      tag = helper.structured_data_tag(:breadcrumb_list) do |breadcrumb|
        breadcrumb.add_item(name: "Home", url: "https://example.com")
        breadcrumb.add_item(name: "Products", url: "https://example.com/products")
      end

      expect(tag).to include('"@type": "BreadcrumbList"')
      expect(tag).to include('"name": "Home"')
    end

    it "raises error for unknown type" do
      expect do
        helper.structured_data_tag(:unknown_type, name: "Test")
      end.to raise_error(ArgumentError, /Unknown structured data type/)
    end
  end

  describe "#structured_data_tags" do
    it "generates multiple script tags from array" do
      org = BetterSeo::StructuredData::Organization.new(name: "Acme")
      person = BetterSeo::StructuredData::Person.new(name: "John")

      tags = helper.structured_data_tags([org, person])

      expect(tags).to include('"@type": "Organization"')
      expect(tags).to include('"@type": "Person"')
      expect(tags.scan("<script").size).to eq(2)
    end

    it "generates multiple tags with mixed types" do
      org = BetterSeo::StructuredData::Organization.new(name: "Acme")
      person = BetterSeo::StructuredData::Person.new(name: "John")

      tags = helper.structured_data_tags([org, person])

      expect(tags).to include('"@type": "Organization"')
      expect(tags).to include('"@type": "Person"')
    end

    it "returns empty string for empty array" do
      tags = helper.structured_data_tags([])
      expect(tags).to eq("")
    end
  end

  describe "#organization_sd" do
    it "creates organization structured data with hash" do
      tag = helper.organization_sd(
        name: "Acme Corp",
        url: "https://acme.com",
        logo: "https://acme.com/logo.png"
      )

      expect(tag).to include('"@type": "Organization"')
      expect(tag).to include('"name": "Acme Corp"')
    end

    it "creates organization with block" do
      tag = helper.organization_sd do |org|
        org.name("Acme Corp")
        org.url("https://acme.com")
      end

      expect(tag).to include('"@type": "Organization"')
      expect(tag).to include('"name": "Acme Corp"')
    end
  end

  describe "#article_sd" do
    it "creates article structured data with hash" do
      tag = helper.article_sd(
        headline: "Test Article",
        author: "John Doe",
        date_published: "2024-01-15"
      )

      expect(tag).to include('"@type": "Article"')
      expect(tag).to include('"headline": "Test Article"')
    end

    it "creates article with block" do
      tag = helper.article_sd do |article|
        article.headline("Test Article")
        article.author("John Doe")
      end

      expect(tag).to include('"@type": "Article"')
      expect(tag).to include('"headline": "Test Article"')
    end
  end

  describe "#person_sd" do
    it "creates person structured data with hash" do
      tag = helper.person_sd(
        name: "John Doe",
        email: "john@example.com"
      )

      expect(tag).to include('"@type": "Person"')
      expect(tag).to include('"name": "John Doe"')
    end

    it "creates person with block" do
      tag = helper.person_sd do |person|
        person.name("John Doe")
        person.email("john@example.com")
      end

      expect(tag).to include('"@type": "Person"')
    end
  end

  describe "#product_sd" do
    it "creates product structured data with hash" do
      tag = helper.product_sd(
        name: "iPhone 15",
        brand: "Apple"
      )

      expect(tag).to include('"@type": "Product"')
      expect(tag).to include('"name": "iPhone 15"')
    end

    it "creates product with block" do
      tag = helper.product_sd do |product|
        product.name("iPhone 15")
        product.brand("Apple")
        product.offers(price: 999.99, price_currency: "USD", availability: "InStock")
      end

      expect(tag).to include('"@type": "Product"')
      expect(tag).to include('"brand": "Apple"')
    end
  end

  describe "#breadcrumb_list_sd" do
    it "creates breadcrumb list with block" do
      tag = helper.breadcrumb_list_sd do |breadcrumb|
        breadcrumb.add_item(name: "Home", url: "https://example.com")
        breadcrumb.add_item(name: "Products", url: "https://example.com/products")
      end

      expect(tag).to include('"@type": "BreadcrumbList"')
      expect(tag).to include('"name": "Home"')
    end

    it "creates breadcrumb list from array" do
      items = [
        { name: "Home", url: "https://example.com" },
        { name: "Products", url: "https://example.com/products" }
      ]

      tag = helper.breadcrumb_list_sd(items: items)

      expect(tag).to include('"@type": "BreadcrumbList"')
      expect(tag).to include('"name": "Home"')
    end
  end

  describe "integration example" do
    it "works with complete page structured data" do
      org_tag = helper.organization_sd do |org|
        org.name("Tech Corp")
        org.url("https://techcorp.com")
      end

      breadcrumb_tag = helper.breadcrumb_list_sd do |bc|
        bc.add_item(name: "Home", url: "https://techcorp.com")
        bc.add_item(name: "Blog", url: "https://techcorp.com/blog")
        bc.add_item(name: "Article", url: "https://techcorp.com/blog/article")
      end

      article_tag = helper.article_sd do |article|
        article.headline("Introduction to Ruby")
        article.author("Jane Smith")
        article.date_published("2024-01-15")
      end

      expect(org_tag).to include('"@type": "Organization"')
      expect(breadcrumb_tag).to include('"@type": "BreadcrumbList"')
      expect(article_tag).to include('"@type": "Article"')
    end
  end
end
