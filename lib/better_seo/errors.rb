# frozen_string_literal: true

module BetterSeo
  # Base error class
  class Error < StandardError; end

  # Configuration errors
  class ConfigurationError < Error; end
  class ValidationError < Error; end

  # DSL errors
  class DSLError < Error; end
  class InvalidBuilderError < DSLError; end

  # Generator errors
  class GeneratorError < Error; end
  class TemplateNotFoundError < GeneratorError; end

  # Validator errors
  class ValidatorError < Error; end
  class InvalidDataError < ValidatorError; end

  # Image errors
  class ImageError < Error; end
  class ImageConversionError < ImageError; end
  class ImageValidationError < ImageError; end

  # I18n errors
  class I18nError < Error; end
  class MissingTranslationError < I18nError; end
end
