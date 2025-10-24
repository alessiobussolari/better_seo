# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::Rails::ModelHelpers do
  describe ".seo_attributes" do
    let(:article_class) do
      Class.new do
        include BetterSeo::Rails::ModelHelpers

        attr_accessor :title, :description, :keywords, :author, :published_at, :cover_image

        seo_attributes(
          title: :title,
          description: :description,
          keywords: :keywords,
          author: :author,
          image: :cover_image_url
        )

        def cover_image_url
          "https://example.com/#{cover_image}" if cover_image
        end

        def initialize(attrs = {})
          attrs.each { |k, v| send("#{k}=", v) }
        end
      end
    end

    it "defines seo_title method" do
      article = article_class.new(title: "My Article")
      expect(article.seo_title).to eq("My Article")
    end

    it "defines seo_description method" do
      article = article_class.new(description: "Article description")
      expect(article.seo_description).to eq("Article description")
    end

    it "defines seo_keywords method" do
      article = article_class.new(keywords: "ruby, rails, seo")
      expect(article.seo_keywords).to eq("ruby, rails, seo")
    end

    it "defines seo_author method" do
      article = article_class.new(author: "John Doe")
      expect(article.seo_author).to eq("John Doe")
    end

    it "defines seo_image method" do
      article = article_class.new(cover_image: "article.jpg")
      expect(article.seo_image).to eq("https://example.com/article.jpg")
    end

    it "returns nil when attribute is not set" do
      article = article_class.new
      expect(article.seo_title).to be_nil
      expect(article.seo_description).to be_nil
    end

    it "handles proc for attribute mapping" do
      klass = Class.new do
        include BetterSeo::Rails::ModelHelpers

        attr_accessor :name

        seo_attributes(
          title: -> { "Article: #{name}" }
        )

        def initialize(name)
          @name = name
        end
      end

      instance = klass.new("Ruby Guide")
      expect(instance.seo_title).to eq("Article: Ruby Guide")
    end

    it "handles method name as symbol" do
      klass = Class.new do
        include BetterSeo::Rails::ModelHelpers

        seo_attributes(title: :custom_title)

        def custom_title
          "Custom Title"
        end
      end

      expect(klass.new.seo_title).to eq("Custom Title")
    end
  end

  describe "#to_seo_hash" do
    let(:article_class) do
      Class.new do
        include BetterSeo::Rails::ModelHelpers

        attr_accessor :title, :description, :keywords, :image_url

        seo_attributes(
          title: :title,
          description: :description,
          keywords: :keywords,
          image: :image_url
        )

        def initialize(attrs = {})
          attrs.each { |k, v| send("#{k}=", v) }
        end
      end
    end

    it "returns hash with all SEO attributes" do
      article = article_class.new(
        title: "My Article",
        description: "Description",
        keywords: "ruby, rails",
        image_url: "https://example.com/image.jpg"
      )

      hash = article.to_seo_hash

      expect(hash[:title]).to eq("My Article")
      expect(hash[:description]).to eq("Description")
      expect(hash[:keywords]).to eq("ruby, rails")
      expect(hash[:image]).to eq("https://example.com/image.jpg")
    end

    it "excludes nil values" do
      article = article_class.new(title: "My Article")

      hash = article.to_seo_hash

      expect(hash[:title]).to eq("My Article")
      expect(hash).not_to have_key(:description)
      expect(hash).not_to have_key(:keywords)
      expect(hash).not_to have_key(:image)
    end

    it "returns empty hash when no SEO attributes defined" do
      klass = Class.new do
        include BetterSeo::Rails::ModelHelpers
      end

      expect(klass.new.to_seo_hash).to eq({})
    end
  end

  describe "complete example" do
    it "works with a complete Article model" do
      article_class = Class.new do
        include BetterSeo::Rails::ModelHelpers

        attr_accessor :title, :excerpt, :tags, :author_name, :featured_image, :slug

        seo_attributes(
          title: -> { "#{title} | My Blog" },
          description: :excerpt,
          keywords: -> { tags.join(", ") if tags },
          author: :author_name,
          image: -> { "https://cdn.example.com/#{featured_image}" if featured_image },
          canonical: -> { "https://myblog.com/articles/#{slug}" if slug }
        )

        def initialize(attrs = {})
          attrs.each { |k, v| send("#{k}=", v) }
        end
      end

      article = article_class.new(
        title: "Ruby on Rails Guide",
        excerpt: "Complete guide to Rails development",
        tags: ["ruby", "rails", "tutorial"],
        author_name: "Jane Doe",
        featured_image: "rails-guide.jpg",
        slug: "ruby-on-rails-guide"
      )

      expect(article.seo_title).to eq("Ruby on Rails Guide | My Blog")
      expect(article.seo_description).to eq("Complete guide to Rails development")
      expect(article.seo_keywords).to eq("ruby, rails, tutorial")
      expect(article.seo_author).to eq("Jane Doe")
      expect(article.seo_image).to eq("https://cdn.example.com/rails-guide.jpg")
      expect(article.seo_canonical).to eq("https://myblog.com/articles/ruby-on-rails-guide")

      hash = article.to_seo_hash
      expect(hash).to eq({
        title: "Ruby on Rails Guide | My Blog",
        description: "Complete guide to Rails development",
        keywords: "ruby, rails, tutorial",
        author: "Jane Doe",
        image: "https://cdn.example.com/rails-guide.jpg",
        canonical: "https://myblog.com/articles/ruby-on-rails-guide"
      })
    end
  end
end
