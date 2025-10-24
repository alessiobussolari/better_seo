# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::Analytics::GoogleAnalytics do
  describe "#initialize" do
    it "creates GA instance with measurement ID" do
      ga = described_class.new("G-XXXXXXXXXX")
      expect(ga.measurement_id).to eq("G-XXXXXXXXXX")
    end

    it "creates GA instance with options" do
      ga = described_class.new("G-XXXXXXXXXX", anonymize_ip: true)
      expect(ga.anonymize_ip).to be true
    end
  end

  describe "#to_script_tag" do
    it "generates GA4 script tag" do
      ga = described_class.new("G-XXXXXXXXXX")
      script = ga.to_script_tag

      expect(script).to include('src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"')
      expect(script).to include("gtag('config', 'G-XXXXXXXXXX')")
      expect(script).to include('async')
    end

    it "includes anonymize_ip when enabled" do
      ga = described_class.new("G-XXXXXXXXXX", anonymize_ip: true)
      script = ga.to_script_tag

      expect(script).to include('"anonymize_ip":true')
    end

    it "includes custom config" do
      ga = described_class.new("G-XXXXXXXXXX")
      script = ga.to_script_tag(page_title: "Custom Title", page_location: "/custom")

      expect(script).to include("page_title")
      expect(script).to include("page_location")
    end

    it "supports nonce for CSP" do
      ga = described_class.new("G-XXXXXXXXXX")
      script = ga.to_script_tag(nonce: "abc123")

      expect(script).to include('nonce="abc123"')
    end
  end

  describe "#track_event" do
    it "generates event tracking code" do
      ga = described_class.new("G-XXXXXXXXXX")
      code = ga.track_event("purchase", value: 99.99, currency: "USD")

      expect(code).to include("gtag('event', 'purchase'")
      expect(code).to include("value")
      expect(code).to include("99.99")
    end

    it "handles events without parameters" do
      ga = described_class.new("G-XXXXXXXXXX")
      code = ga.track_event("click")

      expect(code).to include("gtag('event', 'click'")
    end
  end

  describe "#track_page_view" do
    it "generates page view tracking" do
      ga = described_class.new("G-XXXXXXXXXX")
      code = ga.track_page_view("/about")

      expect(code).to include("gtag('config'")
      expect(code).to include('"page_path":"/about"')
    end

    it "includes page title" do
      ga = described_class.new("G-XXXXXXXXXX")
      code = ga.track_page_view("/about", title: "About Us")

      expect(code).to include('"page_title":"About Us"')
    end
  end

  describe "#ecommerce_purchase" do
    it "generates purchase event" do
      ga = described_class.new("G-XXXXXXXXXX")
      code = ga.ecommerce_purchase(
        transaction_id: "T12345",
        value: 99.99,
        currency: "USD",
        items: [{ item_id: "SKU_123", item_name: "Product", price: 99.99, quantity: 1 }]
      )

      expect(code).to include("gtag('event', 'purchase'")
      expect(code).to include("transaction_id")
      expect(code).to include("T12345")
      expect(code).to include("items")
    end
  end
end
