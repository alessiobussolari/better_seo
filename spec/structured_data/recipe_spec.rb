# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::StructuredData::Recipe do
  describe "initialization" do
    it "creates instance with @type Recipe" do
      recipe = described_class.new
      expect(recipe.to_h["@type"]).to eq("Recipe")
    end

    it "initializes with empty ingredients array" do
      recipe = described_class.new
      expect(recipe.ingredients).to eq([])
    end

    it "initializes with empty instructions array" do
      recipe = described_class.new
      expect(recipe.instructions).to eq([])
    end
  end

  describe "basic properties" do
    let(:recipe) { described_class.new }

    it "sets name" do
      recipe.name("Chocolate Chip Cookies")
      expect(recipe.to_h["name"]).to eq("Chocolate Chip Cookies")
    end

    it "sets description" do
      recipe.description("The best chocolate chip cookies")
      expect(recipe.to_h["description"]).to eq("The best chocolate chip cookies")
    end

    it "sets image" do
      recipe.image("https://example.com/cookies.jpg")
      expect(recipe.to_h["image"]).to eq("https://example.com/cookies.jpg")
    end

    it "sets author as string" do
      recipe.author("Jane Doe")
      expect(recipe.to_h["author"]).to eq("Jane Doe")
    end

    it "sets prep time" do
      recipe.prep_time("PT15M")
      expect(recipe.to_h["prepTime"]).to eq("PT15M")
    end

    it "sets cook time" do
      recipe.cook_time("PT30M")
      expect(recipe.to_h["cookTime"]).to eq("PT30M")
    end

    it "sets total time" do
      recipe.total_time("PT45M")
      expect(recipe.to_h["totalTime"]).to eq("PT45M")
    end

    it "sets recipe yield" do
      recipe.recipe_yield("24 cookies")
      expect(recipe.to_h["recipeYield"]).to eq("24 cookies")
    end

    it "sets recipe category" do
      recipe.recipe_category("Dessert")
      expect(recipe.to_h["recipeCategory"]).to eq("Dessert")
    end

    it "sets recipe cuisine" do
      recipe.recipe_cuisine("American")
      expect(recipe.to_h["recipeCuisine"]).to eq("American")
    end

    it "sets keywords" do
      recipe.keywords(%w[cookies dessert chocolate])
      expect(recipe.to_h["keywords"]).to eq(%w[cookies dessert chocolate])
    end
  end

  describe "#add_ingredient" do
    let(:recipe) { described_class.new }

    it "adds a single ingredient" do
      recipe.add_ingredient("2 cups flour")

      ingredients = recipe.to_h["recipeIngredient"]
      expect(ingredients).to eq(["2 cups flour"])
    end

    it "adds multiple ingredients" do
      recipe.add_ingredient("2 cups flour")
      recipe.add_ingredient("1 cup sugar")
      recipe.add_ingredient("1/2 cup butter")

      ingredients = recipe.to_h["recipeIngredient"]
      expect(ingredients.size).to eq(3)
      expect(ingredients).to eq(["2 cups flour", "1 cup sugar", "1/2 cup butter"])
    end

    it "supports method chaining" do
      recipe.add_ingredient("Flour").add_ingredient("Sugar")

      expect(recipe.to_h["recipeIngredient"].size).to eq(2)
    end
  end

  describe "#add_ingredients" do
    let(:recipe) { described_class.new }

    it "adds multiple ingredients from array" do
      ingredients = ["2 cups flour", "1 cup sugar", "1 tsp vanilla"]
      recipe.add_ingredients(ingredients)

      result = recipe.to_h["recipeIngredient"]
      expect(result).to eq(ingredients)
    end
  end

  describe "#add_instruction" do
    let(:recipe) { described_class.new }

    it "adds a single instruction as string" do
      recipe.add_instruction("Preheat oven to 350°F")

      instructions = recipe.to_h["recipeInstructions"]
      expect(instructions).to be_an(Array)
      expect(instructions.size).to eq(1)
      expect(instructions[0]["@type"]).to eq("HowToStep")
      expect(instructions[0]["text"]).to eq("Preheat oven to 350°F")
      expect(instructions[0]["position"]).to eq(1)
    end

    it "adds multiple instructions with auto-incrementing position" do
      recipe.add_instruction("Mix dry ingredients")
      recipe.add_instruction("Add wet ingredients")
      recipe.add_instruction("Bake for 12 minutes")

      instructions = recipe.to_h["recipeInstructions"]
      expect(instructions.size).to eq(3)
      expect(instructions[0]["position"]).to eq(1)
      expect(instructions[1]["position"]).to eq(2)
      expect(instructions[2]["position"]).to eq(3)
    end

    it "supports method chaining" do
      recipe.add_instruction("Step 1").add_instruction("Step 2")

      expect(recipe.to_h["recipeInstructions"].size).to eq(2)
    end
  end

  describe "#add_instructions" do
    let(:recipe) { described_class.new }

    it "adds multiple instructions from array" do
      instructions = [
        "Mix ingredients",
        "Form into balls",
        "Bake for 12 minutes"
      ]

      recipe.add_instructions(instructions)

      result = recipe.to_h["recipeInstructions"]
      expect(result.size).to eq(3)
      expect(result[0]["text"]).to eq("Mix ingredients")
      expect(result[1]["text"]).to eq("Form into balls")
      expect(result[2]["text"]).to eq("Bake for 12 minutes")
    end
  end

  describe "nutrition information" do
    let(:recipe) { described_class.new }

    it "sets nutrition information" do
      recipe.nutrition(
        calories: "270 calories",
        fat_content: "12g",
        carbohydrate_content: "35g",
        protein_content: "4g"
      )

      nutrition = recipe.to_h["nutrition"]
      expect(nutrition["@type"]).to eq("NutritionInformation")
      expect(nutrition["calories"]).to eq("270 calories")
      expect(nutrition["fatContent"]).to eq("12g")
      expect(nutrition["carbohydrateContent"]).to eq("35g")
      expect(nutrition["proteinContent"]).to eq("4g")
    end
  end

  describe "aggregate rating" do
    let(:recipe) { described_class.new }

    it "sets aggregate rating" do
      recipe.aggregate_rating(
        rating_value: 4.8,
        review_count: 125
      )

      rating = recipe.to_h["aggregateRating"]
      expect(rating["@type"]).to eq("AggregateRating")
      expect(rating["ratingValue"]).to eq(4.8)
      expect(rating["reviewCount"]).to eq(125)
    end
  end

  describe "JSON-LD generation" do
    it "generates valid JSON-LD" do
      recipe = described_class.new
      recipe.name("Chocolate Cake")
      recipe.description("Delicious chocolate cake")
      recipe.prep_time("PT20M")
      recipe.cook_time("PT40M")
      recipe.total_time("PT1H")
      recipe.recipe_yield("8 servings")
      recipe.add_ingredients(["2 cups flour", "1 cup sugar", "1/2 cup cocoa"])
      recipe.add_instructions(["Mix ingredients", "Pour into pan", "Bake at 350°F"])

      json = JSON.parse(recipe.to_json)

      expect(json["@context"]).to eq("https://schema.org")
      expect(json["@type"]).to eq("Recipe")
      expect(json["name"]).to eq("Chocolate Cake")
      expect(json["recipeIngredient"]).to be_an(Array)
      expect(json["recipeInstructions"]).to be_an(Array)
      expect(json["recipeInstructions"][0]["@type"]).to eq("HowToStep")
    end

    it "generates script tag" do
      recipe = described_class.new(name: "Cookies")
      recipe.add_ingredient("Flour")
      recipe.add_instruction("Mix")

      script_tag = recipe.to_script_tag

      expect(script_tag).to include('<script type="application/ld+json">')
      expect(script_tag).to include('"@type": "Recipe"')
      expect(script_tag).to include('"@type": "HowToStep"')
      expect(script_tag).to include("</script>")
    end
  end

  describe "complete example" do
    it "creates complete recipe with all features" do
      recipe = described_class.new
      recipe.name("Perfect Chocolate Chip Cookies")
      recipe.description("The ultimate chocolate chip cookie recipe")
      recipe.image([
                     "https://example.com/cookies-1.jpg",
                     "https://example.com/cookies-2.jpg"
                   ])
      recipe.author("Chef Julia")
      recipe.prep_time("PT15M")
      recipe.cook_time("PT12M")
      recipe.total_time("PT27M")
      recipe.recipe_yield("24 cookies")
      recipe.recipe_category("Dessert")
      recipe.recipe_cuisine("American")
      recipe.keywords(%w[cookies chocolate dessert baking])

      recipe.add_ingredients([
                               "2 cups all-purpose flour",
                               "1 tsp baking soda",
                               "1/2 tsp salt",
                               "1 cup butter, softened",
                               "3/4 cup granulated sugar",
                               "3/4 cup brown sugar",
                               "2 large eggs",
                               "2 tsp vanilla extract",
                               "2 cups chocolate chips"
                             ])

      recipe.add_instructions([
                                "Preheat oven to 375°F (190°C)",
                                "Mix flour, baking soda, and salt in a bowl",
                                "Beat butter and sugars until creamy",
                                "Add eggs and vanilla, beat well",
                                "Gradually blend in flour mixture",
                                "Stir in chocolate chips",
                                "Drop by rounded tablespoons onto ungreased cookie sheets",
                                "Bake 9-11 minutes or until golden brown"
                              ])

      recipe.nutrition(
        calories: "270 calories",
        fat_content: "14g",
        carbohydrate_content: "35g",
        protein_content: "3g",
        sugar_content: "22g"
      )

      recipe.aggregate_rating(
        rating_value: 4.9,
        review_count: 328
      )

      hash = recipe.to_h

      expect(hash["@type"]).to eq("Recipe")
      expect(hash["name"]).to eq("Perfect Chocolate Chip Cookies")
      expect(hash["recipeIngredient"]).to be_an(Array)
      expect(hash["recipeIngredient"].size).to eq(9)
      expect(hash["recipeInstructions"]).to be_an(Array)
      expect(hash["recipeInstructions"].size).to eq(8)
      expect(hash["nutrition"]["@type"]).to eq("NutritionInformation")
      expect(hash["aggregateRating"]["@type"]).to eq("AggregateRating")
    end
  end
end
