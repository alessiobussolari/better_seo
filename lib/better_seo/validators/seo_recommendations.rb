# frozen_string_literal: true

module BetterSeo
  module Validators
    class SeoRecommendations
      def generate_recommendations(validation_result)
        recommendations = []

        recommendations += recommend_title_improvements(validation_result[:title])
        recommendations += recommend_description_improvements(validation_result[:description])
        recommendations += recommend_heading_improvements(validation_result[:headings])
        recommendations += recommend_image_improvements(validation_result[:images])

        # Sort by priority: high, medium, low
        priority_order = { high: 0, medium: 1, low: 2 }
        recommendations.sort_by { |r| priority_order[r[:priority]] }
      end

      def recommend_title_improvements(title_result)
        return [] if title_result[:valid]

        recommendations = []
        length = title_result[:length]

        if length.zero?
          recommendations << {
            category: "Title",
            priority: :high,
            action: "Add a page title",
            details: "A title tag is required for SEO. Aim for 30-60 characters."
          }
        elsif length < 30
          needed = 30 - length
          recommendations << {
            category: "Title",
            priority: :high,
            action: "Make title longer",
            details: "Add approximately #{needed} more characters to reach the optimal length (30-60 chars)."
          }
        elsif length > 60
          excess = length - 60
          recommendations << {
            category: "Title",
            priority: :medium,
            action: "Make title shorter",
            details: "Reduce by approximately #{excess} characters to stay within optimal length (30-60 chars)."
          }
        end

        recommendations
      end

      def recommend_description_improvements(desc_result)
        return [] if desc_result[:valid]

        recommendations = []
        length = desc_result[:length]

        if length.zero?
          recommendations << {
            category: "Meta Description",
            priority: :high,
            action: "Add a meta description",
            details: "Meta descriptions help search engines understand your content. Aim for 120-160 characters."
          }
        elsif length < 120
          needed = 120 - length
          recommendations << {
            category: "Meta Description",
            priority: :medium,
            action: "Add more detail to description",
            details: "Add approximately #{needed} more characters to provide more context (optimal: 120-160 chars)."
          }
        elsif length > 160
          excess = length - 160
          recommendations << {
            category: "Meta Description",
            priority: :medium,
            action: "Condense description",
            details: "Reduce by approximately #{excess} characters to prevent truncation in search results."
          }
        end

        recommendations
      end

      def recommend_heading_improvements(headings_result)
        return [] if headings_result[:valid]

        recommendations = []
        h1_count = headings_result[:h1_count]

        if h1_count.zero?
          recommendations << {
            category: "Headings",
            priority: :high,
            action: "Add an H1 heading",
            details: "Every page should have exactly one H1 tag that describes the main topic."
          }
        elsif h1_count > 1
          recommendations << {
            category: "Headings",
            priority: :high,
            action: "Use only one H1 heading",
            details: "Found #{h1_count} H1 tags. Use H2-H6 for subheadings instead."
          }
        end

        if headings_result[:total_headings].zero?
          recommendations << {
            category: "Headings",
            priority: :medium,
            action: "Add heading structure",
            details: "Use headings (H1-H6) to organize content and improve readability."
          }
        end

        recommendations
      end

      def recommend_image_improvements(images_result)
        return [] if images_result[:valid]

        recommendations = []

        if images_result[:images_without_alt].positive?
          count = images_result[:images_without_alt]
          recommendations << {
            category: "Images",
            priority: :medium,
            action: "Add alt text to images",
            details: "#{count} image#{"s" if count > 1} missing alt text. Alt text improves accessibility and SEO."
          }
        end

        recommendations
      end

      def format_recommendations(recommendations)
        return "# SEO Recommendations\n\nNo recommendations - your SEO is optimal! ✓" if recommendations.empty?

        output = []
        output << "# SEO Recommendations\n"

        # Group by priority
        grouped = recommendations.group_by { |r| r[:priority] }

        %i[high medium low].each do |priority|
          next unless grouped[priority]

          output << "## #{priority.to_s.capitalize} Priority\n"

          grouped[priority].each do |rec|
            output << "### #{rec[:category]}"
            output << "**Action:** #{rec[:action]}\n"
            output << "**Details:** #{rec[:details]}\n" if rec[:details]
            output << ""
          end
        end

        output.join("\n")
      end
    end
  end
end
