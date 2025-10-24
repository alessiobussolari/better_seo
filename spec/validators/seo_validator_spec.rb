# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::Validators::SeoValidator do
  describe "#check_title" do
    it "validates optimal title length (30-60 chars)" do
      validator = described_class.new
      result = validator.check_title("This is an Optimal SEO Title Example")

      expect(result[:valid]).to be true
      expect(result[:score]).to eq(100)
      expect(result[:message]).to include("optimal")
    end

    it "warns for short titles (< 30 chars)" do
      validator = described_class.new
      result = validator.check_title("Short Title")

      expect(result[:valid]).to be false
      expect(result[:score]).to be < 100
      expect(result[:message]).to include("too short")
      expect(result[:length]).to eq(11)
    end

    it "warns for long titles (> 60 chars)" do
      validator = described_class.new
      result = validator.check_title("This is a Very Long Title That Exceeds the Recommended Maximum Length for SEO")

      expect(result[:valid]).to be false
      expect(result[:score]).to be < 100
      expect(result[:message]).to include("too long")
    end

    it "fails for empty title" do
      validator = described_class.new
      result = validator.check_title("")

      expect(result[:valid]).to be false
      expect(result[:score]).to eq(0)
      expect(result[:message]).to include("required")
    end

    it "fails for nil title" do
      validator = described_class.new
      result = validator.check_title(nil)

      expect(result[:valid]).to be false
      expect(result[:score]).to eq(0)
    end
  end

  describe "#check_description" do
    it "validates optimal description length (120-160 chars)" do
      validator = described_class.new
      desc = "This is an optimal SEO meta description with the right length, providing clear value proposition and call to action for users."
      result = validator.check_description(desc)

      expect(result[:valid]).to be true
      expect(result[:score]).to eq(100)
      expect(result[:message]).to include("optimal")
    end

    it "warns for short descriptions (< 120 chars)" do
      validator = described_class.new
      result = validator.check_description("Too short description.")

      expect(result[:valid]).to be false
      expect(result[:score]).to be < 100
      expect(result[:message]).to include("too short")
    end

    it "warns for long descriptions (> 160 chars)" do
      validator = described_class.new
      desc = "This is a very long meta description that significantly exceeds the recommended maximum length for SEO best practices and will likely be truncated in search results."
      result = validator.check_description(desc)

      expect(result[:valid]).to be false
      expect(result[:score]).to be < 100
      expect(result[:message]).to include("too long")
    end

    it "fails for empty description" do
      validator = described_class.new
      result = validator.check_description("")

      expect(result[:valid]).to be false
      expect(result[:score]).to eq(0)
      expect(result[:message]).to include("required")
    end
  end

  describe "#check_headings" do
    it "validates proper heading structure" do
      validator = described_class.new
      html = <<~HTML
        <h1>Main Title</h1>
        <h2>Section 1</h2>
        <h3>Subsection 1.1</h3>
        <h2>Section 2</h2>
      HTML

      result = validator.check_headings(html)

      expect(result[:valid]).to be true
      expect(result[:score]).to eq(100)
      expect(result[:h1_count]).to eq(1)
      expect(result[:total_headings]).to eq(4)
    end

    it "warns for missing H1" do
      validator = described_class.new
      html = "<h2>Section</h2><h3>Subsection</h3>"
      result = validator.check_headings(html)

      expect(result[:valid]).to be false
      expect(result[:message]).to include("H1")
      expect(result[:h1_count]).to eq(0)
    end

    it "warns for multiple H1s" do
      validator = described_class.new
      html = "<h1>Title 1</h1><h1>Title 2</h1>"
      result = validator.check_headings(html)

      expect(result[:valid]).to be false
      expect(result[:message]).to include("Multiple H1")
      expect(result[:h1_count]).to eq(2)
    end

    it "handles HTML without headings" do
      validator = described_class.new
      html = "<p>Just a paragraph</p>"
      result = validator.check_headings(html)

      expect(result[:valid]).to be false
      expect(result[:total_headings]).to eq(0)
    end
  end

  describe "#check_images" do
    it "validates images with alt text" do
      validator = described_class.new
      html = <<~HTML
        <img src="image1.jpg" alt="Description 1">
        <img src="image2.jpg" alt="Description 2">
      HTML

      result = validator.check_images(html)

      expect(result[:valid]).to be true
      expect(result[:score]).to eq(100)
      expect(result[:total_images]).to eq(2)
      expect(result[:images_with_alt]).to eq(2)
      expect(result[:images_without_alt]).to eq(0)
    end

    it "warns for images without alt text" do
      validator = described_class.new
      html = '<img src="image1.jpg"><img src="image2.jpg" alt="Good">'
      result = validator.check_images(html)

      expect(result[:valid]).to be false
      expect(result[:total_images]).to eq(2)
      expect(result[:images_without_alt]).to eq(1)
      expect(result[:message]).to include("missing alt")
    end

    it "warns for images with empty alt text" do
      validator = described_class.new
      html = '<img src="image.jpg" alt="">'
      result = validator.check_images(html)

      expect(result[:valid]).to be false
      expect(result[:images_without_alt]).to eq(1)
    end

    it "handles HTML without images" do
      validator = described_class.new
      html = "<p>No images here</p>"
      result = validator.check_images(html)

      expect(result[:valid]).to be true
      expect(result[:total_images]).to eq(0)
    end
  end

  describe "#validate_page" do
    it "validates complete HTML page" do
      validator = described_class.new
      html = <<~HTML
        <!DOCTYPE html>
        <html>
        <head>
          <title>This is an Optimal SEO Page Title Example</title>
          <meta name="description" content="This is an optimal SEO meta description with the right length, providing clear value proposition and call to action for users.">
        </head>
        <body>
          <h1>Main Title</h1>
          <img src="image.jpg" alt="Image description">
          <p>Content here</p>
        </body>
        </html>
      HTML

      result = validator.validate_page(html)

      expect(result[:overall_score]).to be >= 80
      expect(result[:title][:valid]).to be true
      expect(result[:description][:valid]).to be true
      expect(result[:headings][:valid]).to be true
      expect(result[:images][:valid]).to be true
    end

    it "calculates overall score" do
      validator = described_class.new
      html = <<~HTML
        <title>Good Title for SEO Optimization</title>
        <meta name="description" content="Short">
        <h1>Title</h1><h1>Another Title</h1>
        <img src="img.jpg">
      HTML

      result = validator.validate_page(html)

      expect(result[:overall_score]).to be < 100
      expect(result[:overall_score]).to be > 0
      expect(result[:issues]).to be_an(Array)
      expect(result[:issues].size).to be > 0
    end
  end

  describe "#generate_report" do
    it "generates human-readable report" do
      validator = described_class.new
      html = <<~HTML
        <title>This is an Optimal SEO Page Title Example</title>
        <meta name="description" content="This is an optimal SEO meta description with the right length, providing clear value proposition.">
        <h1>Main Title</h1>
      HTML

      validation = validator.validate_page(html)
      report = validator.generate_report(validation)

      expect(report).to include("Overall Score")
      expect(report).to include("Title")
      expect(report).to include("Description")
      expect(report).to include("Headings")
    end

    it "includes issues in report" do
      validator = described_class.new
      html = "<title>Short</title><h2>No H1</h2>"

      validation = validator.validate_page(html)
      report = validator.generate_report(validation)

      expect(report).to include("Issues")
      expect(report).to include("too short")
    end
  end

  describe "complete validation example" do
    it "validates full page with all checks" do
      validator = described_class.new

      html = <<~HTML
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <title>Best Ruby SEO Gem for Rails Applications</title>
          <meta name="description" content="BetterSeo is a comprehensive SEO gem for Ruby on Rails providing meta tags, structured data, sitemaps, and advanced SEO features.">
          <link rel="canonical" href="https://example.com/seo-gem">
        </head>
        <body>
          <h1>BetterSeo: Complete SEO Solution for Rails</h1>
          <img src="logo.png" alt="BetterSeo Logo">

          <h2>Features</h2>
          <img src="feature1.png" alt="Meta Tags Management">

          <h2>Getting Started</h2>
          <h3>Installation</h3>
          <h3>Configuration</h3>
        </body>
        </html>
      HTML

      result = validator.validate_page(html)

      expect(result[:overall_score]).to be >= 90
      expect(result[:title][:valid]).to be true
      expect(result[:description][:valid]).to be true
      expect(result[:headings][:valid]).to be true
      expect(result[:images][:valid]).to be true
      expect(result[:issues].size).to eq(0)

      report = validator.generate_report(result)
      expect(report).to include("Score")
      expect(report).to be_a(String)
    end
  end
end
