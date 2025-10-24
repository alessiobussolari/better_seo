# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::Sitemap::UrlEntry, "image and video extensions" do
  describe "#add_image" do
    let(:entry) { described_class.new("https://example.com/page") }

    it "adds a single image" do
      entry.add_image("https://example.com/image.jpg")

      images = entry.images
      expect(images.size).to eq(1)
      expect(images[0][:loc]).to eq("https://example.com/image.jpg")
    end

    it "adds image with title and caption" do
      entry.add_image(
        "https://example.com/image.jpg",
        title: "Image Title",
        caption: "Image Caption"
      )

      image = entry.images.first
      expect(image[:loc]).to eq("https://example.com/image.jpg")
      expect(image[:title]).to eq("Image Title")
      expect(image[:caption]).to eq("Image Caption")
    end

    it "adds multiple images" do
      entry.add_image("https://example.com/image1.jpg", title: "Image 1")
      entry.add_image("https://example.com/image2.jpg", title: "Image 2")

      expect(entry.images.size).to eq(2)
    end

    it "supports method chaining" do
      entry.add_image("https://example.com/image1.jpg")
        .add_image("https://example.com/image2.jpg")

      expect(entry.images.size).to eq(2)
    end
  end

  describe "#add_video" do
    let(:entry) { described_class.new("https://example.com/page") }

    it "adds a single video" do
      entry.add_video(
        thumbnail_loc: "https://example.com/thumb.jpg",
        title: "Video Title",
        description: "Video Description",
        content_loc: "https://example.com/video.mp4"
      )

      videos = entry.videos
      expect(videos.size).to eq(1)
      expect(videos[0][:thumbnail_loc]).to eq("https://example.com/thumb.jpg")
      expect(videos[0][:title]).to eq("Video Title")
      expect(videos[0][:description]).to eq("Video Description")
      expect(videos[0][:content_loc]).to eq("https://example.com/video.mp4")
    end

    it "adds video with optional duration" do
      entry.add_video(
        thumbnail_loc: "https://example.com/thumb.jpg",
        title: "Video",
        description: "Description",
        content_loc: "https://example.com/video.mp4",
        duration: 600
      )

      video = entry.videos.first
      expect(video[:duration]).to eq(600)
    end

    it "supports method chaining" do
      entry.add_video(
        thumbnail_loc: "https://example.com/thumb1.jpg",
        title: "Video 1",
        description: "Desc 1",
        content_loc: "https://example.com/video1.mp4"
      ).add_video(
        thumbnail_loc: "https://example.com/thumb2.jpg",
        title: "Video 2",
        description: "Desc 2",
        content_loc: "https://example.com/video2.mp4"
      )

      expect(entry.videos.size).to eq(2)
    end
  end

  describe "#to_xml with images" do
    it "includes image:image tags" do
      entry = described_class.new("https://example.com/page")
      entry.add_image("https://example.com/image.jpg", title: "My Image")

      xml = entry.to_xml

      expect(xml).to include("<image:image>")
      expect(xml).to include("<image:loc>https://example.com/image.jpg</image:loc>")
      expect(xml).to include("<image:title>My Image</image:title>")
      expect(xml).to include("</image:image>")
    end

    it "includes caption when provided" do
      entry = described_class.new("https://example.com/page")
      entry.add_image("https://example.com/image.jpg", caption: "Image caption")

      xml = entry.to_xml

      expect(xml).to include("<image:caption>Image caption</image:caption>")
    end
  end

  describe "#to_xml with videos" do
    it "includes video:video tags" do
      entry = described_class.new("https://example.com/page")
      entry.add_video(
        thumbnail_loc: "https://example.com/thumb.jpg",
        title: "Video Title",
        description: "Video Description",
        content_loc: "https://example.com/video.mp4"
      )

      xml = entry.to_xml

      expect(xml).to include("<video:video>")
      expect(xml).to include("<video:thumbnail_loc>https://example.com/thumb.jpg</video:thumbnail_loc>")
      expect(xml).to include("<video:title>Video Title</video:title>")
      expect(xml).to include("<video:description>Video Description</video:description>")
      expect(xml).to include("<video:content_loc>https://example.com/video.mp4</video:content_loc>")
      expect(xml).to include("</video:video>")
    end

    it "includes duration when provided" do
      entry = described_class.new("https://example.com/page")
      entry.add_video(
        thumbnail_loc: "https://example.com/thumb.jpg",
        title: "Video",
        description: "Desc",
        content_loc: "https://example.com/video.mp4",
        duration: 300
      )

      xml = entry.to_xml

      expect(xml).to include("<video:duration>300</video:duration>")
    end
  end

  describe "complete example with images and videos" do
    it "creates URL entry with both images and videos" do
      entry = described_class.new("https://example.com/product/awesome-product")
      entry.changefreq = "weekly"
      entry.priority = 0.9

      # Add product images
      entry.add_image("https://example.com/images/product-main.jpg", title: "Main Product Image")
      entry.add_image("https://example.com/images/product-alt1.jpg", title: "Alternate View 1")
      entry.add_image("https://example.com/images/product-alt2.jpg", title: "Alternate View 2")

      # Add product video
      entry.add_video(
        thumbnail_loc: "https://example.com/images/video-thumb.jpg",
        title: "Product Demo Video",
        description: "See our product in action",
        content_loc: "https://example.com/videos/product-demo.mp4",
        duration: 120
      )

      xml = entry.to_xml

      # Verify URL structure
      expect(xml).to include("<loc>https://example.com/product/awesome-product</loc>")

      # Verify images
      expect(xml.scan(/<image:image>/).size).to eq(3)
      expect(xml).to include("product-main.jpg")
      expect(xml).to include("product-alt1.jpg")
      expect(xml).to include("product-alt2.jpg")

      # Verify video
      expect(xml.scan(/<video:video>/).size).to eq(1)
      expect(xml).to include("Product Demo Video")
      expect(xml).to include("<video:duration>120</video:duration>")
    end
  end
end
