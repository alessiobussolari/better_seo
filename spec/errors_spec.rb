# frozen_string_literal: true

require "spec_helper"

RSpec.describe "BetterSeo Error Classes" do
  describe "BetterSeo::Error" do
    it "is a StandardError" do
      expect(BetterSeo::Error.new).to be_a(StandardError)
    end

    it "can be raised with a message" do
      expect {
        raise BetterSeo::Error, "test error"
      }.to raise_error(BetterSeo::Error, "test error")
    end
  end

  describe "BetterSeo::ConfigurationError" do
    it "inherits from BetterSeo::Error" do
      expect(BetterSeo::ConfigurationError.new).to be_a(BetterSeo::Error)
    end

    it "can be raised with a message" do
      expect {
        raise BetterSeo::ConfigurationError, "config error"
      }.to raise_error(BetterSeo::ConfigurationError, "config error")
    end
  end

  describe "BetterSeo::ValidationError" do
    it "inherits from BetterSeo::Error" do
      expect(BetterSeo::ValidationError.new).to be_a(BetterSeo::Error)
    end

    it "can be raised with a message" do
      expect {
        raise BetterSeo::ValidationError, "validation error"
      }.to raise_error(BetterSeo::ValidationError, "validation error")
    end
  end

  describe "BetterSeo::DSLError" do
    it "inherits from BetterSeo::Error" do
      expect(BetterSeo::DSLError.new).to be_a(BetterSeo::Error)
    end

    it "can be raised with a message" do
      expect {
        raise BetterSeo::DSLError, "dsl error"
      }.to raise_error(BetterSeo::DSLError, "dsl error")
    end
  end

  describe "BetterSeo::InvalidBuilderError" do
    it "inherits from BetterSeo::DSLError" do
      expect(BetterSeo::InvalidBuilderError.new).to be_a(BetterSeo::DSLError)
    end

    it "can be raised with a message" do
      expect {
        raise BetterSeo::InvalidBuilderError, "invalid builder"
      }.to raise_error(BetterSeo::InvalidBuilderError, "invalid builder")
    end
  end

  describe "BetterSeo::GeneratorError" do
    it "inherits from BetterSeo::Error" do
      expect(BetterSeo::GeneratorError.new).to be_a(BetterSeo::Error)
    end

    it "can be raised with a message" do
      expect {
        raise BetterSeo::GeneratorError, "generator error"
      }.to raise_error(BetterSeo::GeneratorError, "generator error")
    end
  end

  describe "BetterSeo::TemplateNotFoundError" do
    it "inherits from BetterSeo::GeneratorError" do
      expect(BetterSeo::TemplateNotFoundError.new).to be_a(BetterSeo::GeneratorError)
    end

    it "can be raised with a message" do
      expect {
        raise BetterSeo::TemplateNotFoundError, "template not found"
      }.to raise_error(BetterSeo::TemplateNotFoundError, "template not found")
    end
  end

  describe "BetterSeo::ValidatorError" do
    it "inherits from BetterSeo::Error" do
      expect(BetterSeo::ValidatorError.new).to be_a(BetterSeo::Error)
    end

    it "can be raised with a message" do
      expect {
        raise BetterSeo::ValidatorError, "validator error"
      }.to raise_error(BetterSeo::ValidatorError, "validator error")
    end
  end

  describe "BetterSeo::InvalidDataError" do
    it "inherits from BetterSeo::ValidatorError" do
      expect(BetterSeo::InvalidDataError.new).to be_a(BetterSeo::ValidatorError)
    end

    it "can be raised with a message" do
      expect {
        raise BetterSeo::InvalidDataError, "invalid data"
      }.to raise_error(BetterSeo::InvalidDataError, "invalid data")
    end
  end

  describe "BetterSeo::ImageError" do
    it "inherits from BetterSeo::Error" do
      expect(BetterSeo::ImageError.new).to be_a(BetterSeo::Error)
    end

    it "can be raised with a message" do
      expect {
        raise BetterSeo::ImageError, "image error"
      }.to raise_error(BetterSeo::ImageError, "image error")
    end
  end

  describe "BetterSeo::ImageConversionError" do
    it "inherits from BetterSeo::ImageError" do
      expect(BetterSeo::ImageConversionError.new).to be_a(BetterSeo::ImageError)
    end

    it "can be raised with a message" do
      expect {
        raise BetterSeo::ImageConversionError, "conversion error"
      }.to raise_error(BetterSeo::ImageConversionError, "conversion error")
    end
  end

  describe "BetterSeo::ImageValidationError" do
    it "inherits from BetterSeo::ImageError" do
      expect(BetterSeo::ImageValidationError.new).to be_a(BetterSeo::ImageError)
    end

    it "can be raised with a message" do
      expect {
        raise BetterSeo::ImageValidationError, "image validation error"
      }.to raise_error(BetterSeo::ImageValidationError, "image validation error")
    end
  end

  describe "BetterSeo::I18nError" do
    it "inherits from BetterSeo::Error" do
      expect(BetterSeo::I18nError.new).to be_a(BetterSeo::Error)
    end

    it "can be raised with a message" do
      expect {
        raise BetterSeo::I18nError, "i18n error"
      }.to raise_error(BetterSeo::I18nError, "i18n error")
    end
  end

  describe "BetterSeo::MissingTranslationError" do
    it "inherits from BetterSeo::I18nError" do
      expect(BetterSeo::MissingTranslationError.new).to be_a(BetterSeo::I18nError)
    end

    it "can be raised with a message" do
      expect {
        raise BetterSeo::MissingTranslationError, "missing translation"
      }.to raise_error(BetterSeo::MissingTranslationError, "missing translation")
    end
  end
end
