# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::Validators::SeoRecommendations do
  describe "#generate_recommendations" do
    it "generates recommendations from validation results" do
      validator = BetterSeo::Validators::SeoValidator.new
      html = "<title>Short</title><h2>No H1</h2>"
      validation = validator.validate_page(html)

      recommender = described_class.new
      recommendations = recommender.generate_recommendations(validation)

      expect(recommendations).to be_an(Array)
      expect(recommendations.size).to be > 0
    end

    it "prioritizes recommendations by severity" do
      validator = BetterSeo::Validators::SeoValidator.new
      html = "<title>T</title><p>No meta, no headings</p>"
      validation = validator.validate_page(html)

      recommender = described_class.new
      recommendations = recommender.generate_recommendations(validation)

      high_priority = recommendations.select { |r| r[:priority] == :high }
      expect(high_priority.size).to be > 0
    end
  end

  describe "#recommend_title_improvements" do
    it "recommends lengthening short titles" do
      recommender = described_class.new
      result = { valid: false, length: 15, score: 50 }

      recommendations = recommender.recommend_title_improvements(result)

      expect(recommendations.size).to be > 0
      expect(recommendations.first[:action]).to include("longer")
      expect(recommendations.first[:priority]).to eq(:high)
    end

    it "recommends shortening long titles" do
      recommender = described_class.new
      result = { valid: false, length: 75, score: 60 }

      recommendations = recommender.recommend_title_improvements(result)

      expect(recommendations.first[:action]).to include("shorter")
    end

    it "returns no recommendations for optimal titles" do
      recommender = described_class.new
      result = { valid: true, length: 45, score: 100 }

      recommendations = recommender.recommend_title_improvements(result)

      expect(recommendations).to be_empty
    end
  end

  describe "#recommend_description_improvements" do
    it "recommends expanding short descriptions" do
      recommender = described_class.new
      result = { valid: false, length: 80, score: 60 }

      recommendations = recommender.recommend_description_improvements(result)

      expect(recommendations.first[:action]).to include("Add more detail")
    end

    it "recommends condensing long descriptions" do
      recommender = described_class.new
      result = { valid: false, length: 180, score: 70 }

      recommendations = recommender.recommend_description_improvements(result)

      expect(recommendations.first[:action]).to include("Condense")
    end
  end

  describe "#recommend_heading_improvements" do
    it "recommends adding H1 when missing" do
      recommender = described_class.new
      result = { valid: false, h1_count: 0, total_headings: 3 }

      recommendations = recommender.recommend_heading_improvements(result)

      expect(recommendations.first[:action]).to include("Add an H1")
      expect(recommendations.first[:priority]).to eq(:high)
    end

    it "recommends removing extra H1s" do
      recommender = described_class.new
      result = { valid: false, h1_count: 3, total_headings: 5 }

      recommendations = recommender.recommend_heading_improvements(result)

      expect(recommendations.first[:action]).to include("Use only one H1")
    end
  end

  describe "#recommend_image_improvements" do
    it "recommends adding alt text to images" do
      recommender = described_class.new
      result = { valid: false, total_images: 5, images_without_alt: 3 }

      recommendations = recommender.recommend_image_improvements(result)

      expect(recommendations.first[:action]).to include("Add alt text")
      expect(recommendations.first[:details]).to include("3 images")
    end

    it "returns no recommendations when all images have alt" do
      recommender = described_class.new
      result = { valid: true, total_images: 5, images_without_alt: 0 }

      recommendations = recommender.recommend_image_improvements(result)

      expect(recommendations).to be_empty
    end
  end

  describe "#format_recommendations" do
    it "formats recommendations as markdown" do
      recommender = described_class.new
      recommendations = [
        { category: "Title", priority: :high, action: "Make it longer", details: "Add 20 chars" },
        { category: "Images", priority: :medium, action: "Add alt text", details: "3 images missing" }
      ]

      markdown = recommender.format_recommendations(recommendations)

      expect(markdown).to include("# SEO Recommendations")
      expect(markdown).to include("## High Priority")
      expect(markdown).to include("Title")
      expect(markdown).to include("Make it longer")
    end

    it "groups recommendations by priority" do
      recommender = described_class.new
      recommendations = [
        { category: "Title", priority: :high, action: "Fix" },
        { category: "Desc", priority: :low, action: "Improve" },
        { category: "H1", priority: :medium, action: "Add" }
      ]

      markdown = recommender.format_recommendations(recommendations)

      # Check that high priority comes before medium and low
      high_pos = markdown.index("High Priority")
      medium_pos = markdown.index("Medium Priority")
      low_pos = markdown.index("Low Priority")

      expect(high_pos).to be < medium_pos
      expect(medium_pos).to be < low_pos
    end
  end

  describe "complete recommendations workflow" do
    it "generates and formats complete recommendations" do
      validator = BetterSeo::Validators::SeoValidator.new
      html = <<~HTML
        <title>Bad</title>
        <meta name="description" content="Short">
        <h2>No H1</h2>
        <img src="test.jpg">
      HTML

      validation = validator.validate_page(html)

      recommender = described_class.new
      recommendations = recommender.generate_recommendations(validation)
      markdown = recommender.format_recommendations(recommendations)

      expect(recommendations.size).to be >= 4  # Title, desc, headings, images
      expect(markdown).to include("# SEO Recommendations")
      expect(markdown).to be_a(String)
    end
  end
end
