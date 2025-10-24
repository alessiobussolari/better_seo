# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::Sitemap::UrlEntry, "hreflang support" do
  describe "#add_alternate" do
    let(:entry) { described_class.new("https://example.com/page") }

    it "adds a single alternate language version" do
      entry.add_alternate("https://example.com/es/page", hreflang: "es")

      alternates = entry.alternates
      expect(alternates).to be_an(Array)
      expect(alternates.size).to eq(1)
      expect(alternates[0][:href]).to eq("https://example.com/es/page")
      expect(alternates[0][:hreflang]).to eq("es")
    end

    it "adds multiple alternate language versions" do
      entry.add_alternate("https://example.com/es/page", hreflang: "es")
      entry.add_alternate("https://example.com/fr/page", hreflang: "fr")
      entry.add_alternate("https://example.com/de/page", hreflang: "de")

      alternates = entry.alternates
      expect(alternates.size).to eq(3)
      expect(alternates.map { |a| a[:hreflang] }).to eq(%w[es fr de])
    end

    it "supports x-default alternate" do
      entry.add_alternate("https://example.com/page", hreflang: "x-default")

      alternate = entry.alternates.first
      expect(alternate[:hreflang]).to eq("x-default")
    end

    it "supports region-specific alternates" do
      entry.add_alternate("https://example.com/en-us/page", hreflang: "en-US")
      entry.add_alternate("https://example.com/en-gb/page", hreflang: "en-GB")

      alternates = entry.alternates
      expect(alternates.size).to eq(2)
      expect(alternates[0][:hreflang]).to eq("en-US")
      expect(alternates[1][:hreflang]).to eq("en-GB")
    end

    it "supports method chaining" do
      entry.add_alternate("https://example.com/es/page", hreflang: "es")
           .add_alternate("https://example.com/fr/page", hreflang: "fr")

      expect(entry.alternates.size).to eq(2)
    end
  end

  describe "#to_xml with alternates" do
    it "includes xhtml:link tags for alternates" do
      entry = described_class.new("https://example.com/page")
      entry.add_alternate("https://example.com/es/page", hreflang: "es")
      entry.add_alternate("https://example.com/fr/page", hreflang: "fr")

      xml = entry.to_xml

      expect(xml).to include("<xhtml:link")
      expect(xml).to include('rel="alternate"')
      expect(xml).to include('hreflang="es"')
      expect(xml).to include('href="https://example.com/es/page"')
      expect(xml).to include('hreflang="fr"')
      expect(xml).to include('href="https://example.com/fr/page"')
    end

    it "generates valid XML structure with alternates" do
      entry = described_class.new("https://example.com/page")
      entry.add_alternate("https://example.com/es/page", hreflang: "es")

      xml = entry.to_xml

      expect(xml).to include("<url>")
      expect(xml).to include("<loc>https://example.com/page</loc>")
      expect(xml).to include('hreflang="es"')
      expect(xml).to include("</url>")
    end

    it "does not include xhtml:link when no alternates" do
      entry = described_class.new("https://example.com/page")
      xml = entry.to_xml

      expect(xml).not_to include("xhtml:link")
    end
  end

  describe "#to_h with alternates" do
    it "includes alternates in hash representation" do
      entry = described_class.new("https://example.com/page")
      entry.add_alternate("https://example.com/es/page", hreflang: "es")
      entry.add_alternate("https://example.com/fr/page", hreflang: "fr")

      hash = entry.to_h

      expect(hash[:alternates]).to be_an(Array)
      expect(hash[:alternates].size).to eq(2)
      expect(hash[:alternates][0]).to eq({ href: "https://example.com/es/page", hreflang: "es" })
      expect(hash[:alternates][1]).to eq({ href: "https://example.com/fr/page", hreflang: "fr" })
    end

    it "does not include alternates key when empty" do
      entry = described_class.new("https://example.com/page")
      hash = entry.to_h

      expect(hash).not_to have_key(:alternates)
    end
  end

  describe "complete multi-language example" do
    it "creates URL entry with multiple language versions" do
      entry = described_class.new("https://example.com/en/products")
      entry.lastmod = Date.new(2024, 1, 15)
      entry.changefreq = "weekly"
      entry.priority = 0.8

      # Add language alternates
      entry.add_alternate("https://example.com/en/products", hreflang: "en")
      entry.add_alternate("https://example.com/es/productos", hreflang: "es")
      entry.add_alternate("https://example.com/fr/produits", hreflang: "fr")
      entry.add_alternate("https://example.com/de/produkte", hreflang: "de")
      entry.add_alternate("https://example.com/en/products", hreflang: "x-default")

      xml = entry.to_xml

      # Check main URL
      expect(xml).to include("<loc>https://example.com/en/products</loc>")
      expect(xml).to include("<changefreq>weekly</changefreq>")
      expect(xml).to include("<priority>0.8</priority>")

      # Check all language alternates
      expect(xml).to include('hreflang="en"')
      expect(xml).to include('hreflang="es"')
      expect(xml).to include('hreflang="fr"')
      expect(xml).to include('hreflang="de"')
      expect(xml).to include('hreflang="x-default"')

      expect(xml).to include("https://example.com/es/productos")
      expect(xml).to include("https://example.com/fr/produits")
      expect(xml).to include("https://example.com/de/produkte")

      # Verify hash representation
      hash = entry.to_h
      expect(hash[:alternates].size).to eq(5)
    end
  end
end
