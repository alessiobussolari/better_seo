# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::StructuredData::HowTo do
  describe "initialization" do
    it "creates instance with @type HowTo" do
      how_to = described_class.new
      expect(how_to.to_h["@type"]).to eq("HowTo")
    end

    it "initializes with empty steps array" do
      how_to = described_class.new
      expect(how_to.steps).to eq([])
    end
  end

  describe "basic properties" do
    let(:how_to) { described_class.new }

    it "sets name" do
      how_to.name("How to Make Pizza")
      expect(how_to.to_h["name"]).to eq("How to Make Pizza")
    end

    it "sets description" do
      how_to.description("Learn to make authentic Italian pizza")
      expect(how_to.to_h["description"]).to eq("Learn to make authentic Italian pizza")
    end

    it "sets image" do
      how_to.image("https://example.com/pizza.jpg")
      expect(how_to.to_h["image"]).to eq("https://example.com/pizza.jpg")
    end

    it "sets total time" do
      how_to.total_time("PT2H")
      expect(how_to.to_h["totalTime"]).to eq("PT2H")
    end

    it "sets supply" do
      how_to.supply(["Flour", "Water", "Yeast"])
      expect(how_to.to_h["supply"]).to eq(["Flour", "Water", "Yeast"])
    end

    it "sets tool" do
      how_to.tool(["Oven", "Rolling Pin"])
      expect(how_to.to_h["tool"]).to eq(["Oven", "Rolling Pin"])
    end
  end

  describe "#add_step" do
    let(:how_to) { described_class.new }

    it "adds a single step" do
      how_to.add_step(
        name: "Prepare dough",
        text: "Mix flour, water, and yeast"
      )

      steps = how_to.to_h["step"]
      expect(steps).to be_an(Array)
      expect(steps.size).to eq(1)
      expect(steps[0]["@type"]).to eq("HowToStep")
      expect(steps[0]["name"]).to eq("Prepare dough")
      expect(steps[0]["text"]).to eq("Mix flour, water, and yeast")
    end

    it "adds multiple steps with auto-incrementing position" do
      how_to.add_step(name: "Step 1", text: "Do this")
      how_to.add_step(name: "Step 2", text: "Do that")
      how_to.add_step(name: "Step 3", text: "Done")

      steps = how_to.to_h["step"]
      expect(steps.size).to eq(3)
      expect(steps[0]["position"]).to eq(1)
      expect(steps[1]["position"]).to eq(2)
      expect(steps[2]["position"]).to eq(3)
    end

    it "allows manual position override" do
      how_to.add_step(name: "Step", text: "Text", position: 5)

      steps = how_to.to_h["step"]
      expect(steps[0]["position"]).to eq(5)
    end

    it "supports image and url in steps" do
      how_to.add_step(
        name: "Roll dough",
        text: "Roll the dough flat",
        image: "https://example.com/roll.jpg",
        url: "https://example.com/guide#step2"
      )

      step = how_to.to_h["step"][0]
      expect(step["image"]).to eq("https://example.com/roll.jpg")
      expect(step["url"]).to eq("https://example.com/guide#step2")
    end

    it "supports method chaining" do
      how_to.add_step(name: "Step 1", text: "First")
        .add_step(name: "Step 2", text: "Second")

      expect(how_to.to_h["step"].size).to eq(2)
    end
  end

  describe "#add_steps" do
    let(:how_to) { described_class.new }

    it "adds multiple steps from array" do
      steps = [
        { name: "Mix ingredients", text: "Combine flour and water" },
        { name: "Knead dough", text: "Knead for 10 minutes" },
        { name: "Let rise", text: "Wait 1 hour" }
      ]

      how_to.add_steps(steps)

      result = how_to.to_h["step"]
      expect(result.size).to eq(3)
      expect(result[0]["name"]).to eq("Mix ingredients")
      expect(result[1]["name"]).to eq("Knead dough")
      expect(result[2]["name"]).to eq("Let rise")
    end
  end

  describe "#clear" do
    let(:how_to) { described_class.new }

    it "clears all steps" do
      how_to.add_step(name: "Step 1", text: "Text")
      how_to.add_step(name: "Step 2", text: "Text")

      expect(how_to.to_h["step"].size).to eq(2)

      how_to.clear

      expect(how_to.to_h["step"]).to be_nil
      expect(how_to.steps).to eq([])
    end
  end

  describe "JSON-LD generation" do
    it "generates valid JSON-LD" do
      how_to = described_class.new
      how_to.name("How to Make Coffee")
      how_to.description("Simple coffee brewing guide")
      how_to.total_time("PT10M")
      how_to.supply(["Coffee beans", "Water"])
      how_to.tool(["Coffee maker"])
      how_to.add_step(name: "Add water", text: "Pour water into reservoir")
      how_to.add_step(name: "Add coffee", text: "Add ground coffee to filter")
      how_to.add_step(name: "Brew", text: "Turn on coffee maker")

      json = JSON.parse(how_to.to_json)

      expect(json["@context"]).to eq("https://schema.org")
      expect(json["@type"]).to eq("HowTo")
      expect(json["name"]).to eq("How to Make Coffee")
      expect(json["step"]).to be_an(Array)
      expect(json["step"].size).to eq(3)
      expect(json["supply"]).to eq(["Coffee beans", "Water"])
      expect(json["tool"]).to eq(["Coffee maker"])
    end

    it "generates script tag" do
      how_to = described_class.new(name: "How to Cook")
      how_to.add_step(name: "Step 1", text: "Start")

      script_tag = how_to.to_script_tag

      expect(script_tag).to include('<script type="application/ld+json">')
      expect(script_tag).to include('"@type": "HowTo"')
      expect(script_tag).to include('"@type": "HowToStep"')
      expect(script_tag).to include('</script>')
    end
  end

  describe "complete example" do
    it "creates complete how-to guide" do
      how_to = described_class.new
      how_to.name("How to Build a Website")
      how_to.description("Complete guide to building your first website")
      how_to.image("https://example.com/website-guide.jpg")
      how_to.total_time("PT3H")
      how_to.supply(["Computer", "Text editor", "Web browser"])
      how_to.tool(["VS Code", "Git"])

      how_to.add_steps([
        {
          name: "Set up development environment",
          text: "Install Node.js, VS Code, and Git on your computer",
          image: "https://example.com/setup.jpg"
        },
        {
          name: "Create HTML file",
          text: "Create an index.html file with basic structure",
          url: "https://example.com/guide#html"
        },
        {
          name: "Add CSS styling",
          text: "Create a styles.css file and link it to your HTML"
        },
        {
          name: "Deploy website",
          text: "Upload your files to a web hosting service"
        }
      ])

      hash = how_to.to_h

      expect(hash["@type"]).to eq("HowTo")
      expect(hash["name"]).to eq("How to Build a Website")
      expect(hash["totalTime"]).to eq("PT3H")
      expect(hash["supply"]).to be_an(Array)
      expect(hash["tool"]).to be_an(Array)
      expect(hash["step"]).to be_an(Array)
      expect(hash["step"].size).to eq(4)
      expect(hash["step"][0]["position"]).to eq(1)
      expect(hash["step"][3]["position"]).to eq(4)
    end
  end
end
