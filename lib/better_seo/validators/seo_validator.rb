# frozen_string_literal: true

module BetterSeo
  module Validators
    class SeoValidator
      TITLE_MIN_LENGTH = 30
      TITLE_MAX_LENGTH = 60
      DESCRIPTION_MIN_LENGTH = 120
      DESCRIPTION_MAX_LENGTH = 160

      def check_title(title)
        return { valid: false, score: 0, message: "Title is required", length: 0 } if title.nil? || title.empty?

        length = title.length

        if length >= TITLE_MIN_LENGTH && length <= TITLE_MAX_LENGTH
          { valid: true, score: 100, message: "Title length is optimal", length: length }
        elsif length < TITLE_MIN_LENGTH
          score = (length.to_f / TITLE_MIN_LENGTH * 70).to_i
          { valid: false, score: score, message: "Title is too short (minimum #{TITLE_MIN_LENGTH} characters recommended)", length: length }
        else
          score = [100 - (length - TITLE_MAX_LENGTH) * 2, 50].max
          { valid: false, score: score, message: "Title is too long (maximum #{TITLE_MAX_LENGTH} characters recommended)", length: length }
        end
      end

      def check_description(description)
        return { valid: false, score: 0, message: "Description is required", length: 0 } if description.nil? || description.empty?

        length = description.length

        if length >= DESCRIPTION_MIN_LENGTH && length <= DESCRIPTION_MAX_LENGTH
          { valid: true, score: 100, message: "Description length is optimal", length: length }
        elsif length < DESCRIPTION_MIN_LENGTH
          score = (length.to_f / DESCRIPTION_MIN_LENGTH * 70).to_i
          { valid: false, score: score, message: "Description is too short (minimum #{DESCRIPTION_MIN_LENGTH} characters recommended)", length: length }
        else
          score = [100 - (length - DESCRIPTION_MAX_LENGTH), 50].max
          { valid: false, score: score, message: "Description is too long (maximum #{DESCRIPTION_MAX_LENGTH} characters recommended)", length: length }
        end
      end

      def check_headings(html)
        h1_count = html.scan(/<h1[^>]*>/).size
        h2_count = html.scan(/<h2[^>]*>/).size
        h3_count = html.scan(/<h3[^>]*>/).size
        h4_count = html.scan(/<h4[^>]*>/).size
        h5_count = html.scan(/<h5[^>]*>/).size
        h6_count = html.scan(/<h6[^>]*>/).size

        total = h1_count + h2_count + h3_count + h4_count + h5_count + h6_count

        result = {
          h1_count: h1_count,
          h2_count: h2_count,
          h3_count: h3_count,
          total_headings: total
        }

        if h1_count == 0
          result.merge(valid: false, score: 50, message: "Missing H1 heading (exactly one H1 required)")
        elsif h1_count > 1
          result.merge(valid: false, score: 70, message: "Multiple H1 headings found (only one H1 recommended)")
        elsif total == 0
          result.merge(valid: false, score: 0, message: "No headings found")
        else
          result.merge(valid: true, score: 100, message: "Heading structure is optimal")
        end
      end

      def check_images(html)
        # Find all img tags
        images = html.scan(/<img[^>]*>/)
        total = images.size

        return { valid: true, score: 100, total_images: 0, images_with_alt: 0, images_without_alt: 0, message: "No images to validate" } if total.zero?

        # Count images with alt text
        images_with_alt = images.count { |img| img =~ /alt=["'][^"']+["']/ }
        images_without_alt = total - images_with_alt

        result = {
          total_images: total,
          images_with_alt: images_with_alt,
          images_without_alt: images_without_alt
        }

        if images_without_alt.zero?
          result.merge(valid: true, score: 100, message: "All images have alt text")
        else
          score = (images_with_alt.to_f / total * 100).to_i
          result.merge(valid: false, score: score, message: "#{images_without_alt} image(s) missing alt text")
        end
      end

      def validate_page(html)
        # Extract title
        title_match = html.match(/<title[^>]*>(.*?)<\/title>/m)
        title = title_match ? title_match[1].strip : nil

        # Extract meta description
        desc_match = html.match(/<meta\s+name=["']description["']\s+content=["'](.*?)["']/i)
        description = desc_match ? desc_match[1] : nil

        # Run all checks
        title_result = check_title(title)
        description_result = check_description(description)
        headings_result = check_headings(html)
        images_result = check_images(html)

        # Calculate overall score (weighted average)
        overall_score = (
          title_result[:score] * 0.3 +
          description_result[:score] * 0.3 +
          headings_result[:score] * 0.2 +
          images_result[:score] * 0.2
        ).to_i

        # Collect issues
        issues = []
        issues << "Title: #{title_result[:message]}" unless title_result[:valid]
        issues << "Description: #{description_result[:message]}" unless description_result[:valid]
        issues << "Headings: #{headings_result[:message]}" unless headings_result[:valid]
        issues << "Images: #{images_result[:message]}" unless images_result[:valid]

        {
          overall_score: overall_score,
          title: title_result,
          description: description_result,
          headings: headings_result,
          images: images_result,
          issues: issues
        }
      end

      def generate_report(validation)
        report = []
        report << "=" * 60
        report << "SEO Validation Report"
        report << "=" * 60
        report << ""
        report << "Overall Score: #{validation[:overall_score]}/100"
        report << ""

        # Title section
        report << "Title:"
        report << "  Status: #{validation[:title][:valid] ? '✓' : '✗'}"
        report << "  Score: #{validation[:title][:score]}/100"
        report << "  Length: #{validation[:title][:length]} chars"
        report << "  Message: #{validation[:title][:message]}"
        report << ""

        # Description section
        report << "Description:"
        report << "  Status: #{validation[:description][:valid] ? '✓' : '✗'}"
        report << "  Score: #{validation[:description][:score]}/100"
        report << "  Length: #{validation[:description][:length]} chars"
        report << "  Message: #{validation[:description][:message]}"
        report << ""

        # Headings section
        report << "Headings:"
        report << "  Status: #{validation[:headings][:valid] ? '✓' : '✗'}"
        report << "  Score: #{validation[:headings][:score]}/100"
        report << "  H1 Count: #{validation[:headings][:h1_count]}"
        report << "  Total Headings: #{validation[:headings][:total_headings]}"
        report << "  Message: #{validation[:headings][:message]}"
        report << ""

        # Images section
        report << "Images:"
        report << "  Status: #{validation[:images][:valid] ? '✓' : '✗'}"
        report << "  Score: #{validation[:images][:score]}/100"
        report << "  Total Images: #{validation[:images][:total_images]}"
        report << "  With Alt: #{validation[:images][:images_with_alt]}"
        report << "  Without Alt: #{validation[:images][:images_without_alt]}"
        report << "  Message: #{validation[:images][:message]}"
        report << ""

        # Issues section
        if validation[:issues].any?
          report << "Issues:"
          validation[:issues].each do |issue|
            report << "  - #{issue}"
          end
          report << ""
        end

        report << "=" * 60

        report.join("\n")
      end
    end
  end
end
