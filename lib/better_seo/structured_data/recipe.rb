# frozen_string_literal: true

module BetterSeo
  module StructuredData
    class Recipe < Base
      attr_reader :ingredients, :instructions

      def initialize(**properties)
        super("Recipe", **properties)
        @ingredients = []
        @instructions = []
      end

      # Basic properties
      def name(value)
        set(:name, value)
      end

      def description(value)
        set(:description, value)
      end

      def image(value)
        set(:image, value)
      end

      def author(value)
        set(:author, value)
      end

      def prep_time(value)
        set(:prepTime, value)
      end

      def cook_time(value)
        set(:cookTime, value)
      end

      def total_time(value)
        set(:totalTime, value)
      end

      def recipe_yield(value)
        set(:recipeYield, value)
      end

      def recipe_category(value)
        set(:recipeCategory, value)
      end

      def recipe_cuisine(value)
        set(:recipeCuisine, value)
      end

      def keywords(value)
        set(:keywords, value)
      end

      # Ingredients
      def add_ingredient(ingredient)
        @ingredients << ingredient
        self
      end

      def add_ingredients(ingredients_array)
        @ingredients.concat(ingredients_array)
        self
      end

      # Instructions
      def add_instruction(instruction)
        @instructions << instruction
        self
      end

      def add_instructions(instructions_array)
        @instructions.concat(instructions_array)
        self
      end

      # Nutrition information
      def nutrition(calories: nil, fat_content: nil, carbohydrate_content: nil, protein_content: nil, sugar_content: nil, **other)
        nutrition_hash = {
          "@type" => "NutritionInformation"
        }

        nutrition_hash["calories"] = calories if calories
        nutrition_hash["fatContent"] = fat_content if fat_content
        nutrition_hash["carbohydrateContent"] = carbohydrate_content if carbohydrate_content
        nutrition_hash["proteinContent"] = protein_content if protein_content
        nutrition_hash["sugarContent"] = sugar_content if sugar_content

        other.each do |key, value|
          nutrition_hash[key.to_s.camelize(:lower)] = value if value
        end

        set(:nutrition, nutrition_hash)
      end

      # Aggregate rating
      def aggregate_rating(rating_value:, review_count:, best_rating: 5, worst_rating: 1)
        rating = {
          "@type" => "AggregateRating",
          "ratingValue" => rating_value,
          "reviewCount" => review_count,
          "bestRating" => best_rating,
          "worstRating" => worst_rating
        }

        set(:aggregateRating, rating)
      end

      # Override to_h to include ingredients and instructions
      def to_h
        hash = super

        if @ingredients.any?
          hash["recipeIngredient"] = @ingredients
        end

        if @instructions.any?
          hash["recipeInstructions"] = @instructions.map.with_index(1) do |instruction, index|
            {
              "@type" => "HowToStep",
              "position" => index,
              "text" => instruction
            }
          end
        end

        hash
      end
    end
  end
end
