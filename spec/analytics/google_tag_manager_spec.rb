# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::Analytics::GoogleTagManager do
  describe "#initialize" do
    it "creates GTM instance with container ID" do
      gtm = described_class.new("GTM-XXXXXX")
      expect(gtm.container_id).to eq("GTM-XXXXXX")
    end

    it "creates GTM with custom data layer" do
      gtm = described_class.new("GTM-XXXXXX", data_layer_name: "customDataLayer")
      expect(gtm.data_layer_name).to eq("customDataLayer")
    end
  end

  describe "#to_head_script" do
    it "generates GTM head script tag" do
      gtm = described_class.new("GTM-XXXXXX")
      script = gtm.to_head_script

      expect(script).to include("GTM-XXXXXX")
      expect(script).to include("googletagmanager.com/gtm.js")
      expect(script).to include("dataLayer")
    end

    it "uses custom data layer name" do
      gtm = described_class.new("GTM-XXXXXX", data_layer_name: "myDataLayer")
      script = gtm.to_head_script

      expect(script).to include("myDataLayer")
    end

    it "supports nonce for CSP" do
      gtm = described_class.new("GTM-XXXXXX")
      script = gtm.to_head_script(nonce: "abc123")

      expect(script).to include('nonce="abc123"')
    end
  end

  describe "#to_body_noscript" do
    it "generates GTM body noscript tag" do
      gtm = described_class.new("GTM-XXXXXX")
      noscript = gtm.to_body_noscript

      expect(noscript).to include("<noscript>")
      expect(noscript).to include("GTM-XXXXXX")
      expect(noscript).to include("googletagmanager.com/ns.html")
    end
  end

  describe "#push_data_layer" do
    it "generates data layer push code" do
      gtm = described_class.new("GTM-XXXXXX")
      code = gtm.push_data_layer(event: "customEvent", category: "test")

      expect(code).to include("dataLayer.push")
      expect(code).to include('"event":"customEvent"')
      expect(code).to include('"category":"test"')
    end

    it "uses custom data layer name" do
      gtm = described_class.new("GTM-XXXXXX", data_layer_name: "myDataLayer")
      code = gtm.push_data_layer(event: "test")

      expect(code).to include("myDataLayer.push")
    end
  end

  describe "#push_ecommerce" do
    it "generates e-commerce data layer push" do
      gtm = described_class.new("GTM-XXXXXX")
      code = gtm.push_ecommerce(
        event: "purchase",
        ecommerce: {
          transaction_id: "T12345",
          value: 99.99,
          currency: "USD"
        }
      )

      expect(code).to include("dataLayer.push")
      expect(code).to include('"event":"purchase"')
      expect(code).to include('"ecommerce"')
      expect(code).to include("T12345")
    end
  end

  describe "#push_user_data" do
    it "generates user data layer push" do
      gtm = described_class.new("GTM-XXXXXX")
      code = gtm.push_user_data(user_id: "123", user_type: "premium")

      expect(code).to include("dataLayer.push")
      expect(code).to include('"user_id":"123"')
      expect(code).to include('"user_type":"premium"')
    end
  end

  describe "complete GTM setup" do
    it "provides all required tags for GTM" do
      gtm = described_class.new("GTM-XXXXXX")

      head_script = gtm.to_head_script
      body_noscript = gtm.to_body_noscript

      expect(head_script).to include("GTM-XXXXXX")
      expect(body_noscript).to include("GTM-XXXXXX")
    end
  end
end
