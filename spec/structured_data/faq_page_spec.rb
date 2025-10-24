# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::StructuredData::FAQPage do
  describe "initialization" do
    it "creates instance with @type FAQPage" do
      faq = described_class.new
      expect(faq.to_h["@type"]).to eq("FAQPage")
    end

    it "initializes with empty questions array" do
      faq = described_class.new
      expect(faq.questions).to eq([])
    end
  end

  describe "#add_question" do
    let(:faq) { described_class.new }

    it "adds a question and answer" do
      faq.add_question(
        question: "What is Ruby?",
        answer: "Ruby is a dynamic programming language."
      )

      questions = faq.to_h["mainEntity"]
      expect(questions).to be_an(Array)
      expect(questions.size).to eq(1)
      expect(questions[0]["@type"]).to eq("Question")
      expect(questions[0]["name"]).to eq("What is Ruby?")
      expect(questions[0]["acceptedAnswer"]["@type"]).to eq("Answer")
      expect(questions[0]["acceptedAnswer"]["text"]).to eq("Ruby is a dynamic programming language.")
    end

    it "adds multiple questions" do
      faq.add_question(question: "What is Ruby?", answer: "A programming language")
      faq.add_question(question: "What is Rails?", answer: "A web framework")

      questions = faq.to_h["mainEntity"]
      expect(questions.size).to eq(2)
      expect(questions[0]["name"]).to eq("What is Ruby?")
      expect(questions[1]["name"]).to eq("What is Rails?")
    end

    it "supports method chaining" do
      faq.add_question(question: "Q1?", answer: "A1")
        .add_question(question: "Q2?", answer: "A2")

      expect(faq.to_h["mainEntity"].size).to eq(2)
    end
  end

  describe "#add_questions" do
    let(:faq) { described_class.new }

    it "adds multiple questions from array" do
      questions = [
        { question: "What is Ruby?", answer: "A programming language" },
        { question: "What is Rails?", answer: "A web framework" },
        { question: "What is RSpec?", answer: "A testing framework" }
      ]

      faq.add_questions(questions)

      main_entity = faq.to_h["mainEntity"]
      expect(main_entity.size).to eq(3)
      expect(main_entity[0]["name"]).to eq("What is Ruby?")
      expect(main_entity[1]["name"]).to eq("What is Rails?")
      expect(main_entity[2]["name"]).to eq("What is RSpec?")
    end

    it "supports method chaining" do
      faq.add_questions([
        { question: "Q1?", answer: "A1" }
      ]).add_question(question: "Q2?", answer: "A2")

      expect(faq.to_h["mainEntity"].size).to eq(2)
    end
  end

  describe "#clear" do
    let(:faq) { described_class.new }

    it "clears all questions" do
      faq.add_question(question: "Q1?", answer: "A1")
      faq.add_question(question: "Q2?", answer: "A2")

      expect(faq.to_h["mainEntity"].size).to eq(2)

      faq.clear

      expect(faq.to_h["mainEntity"]).to be_nil
      expect(faq.questions).to eq([])
    end
  end

  describe "JSON-LD generation" do
    it "generates valid JSON-LD" do
      faq = described_class.new
      faq.add_question(
        question: "What is SEO?",
        answer: "SEO stands for Search Engine Optimization."
      )
      faq.add_question(
        question: "Why is SEO important?",
        answer: "SEO helps improve your website's visibility in search results."
      )

      json = JSON.parse(faq.to_json)

      expect(json["@context"]).to eq("https://schema.org")
      expect(json["@type"]).to eq("FAQPage")
      expect(json["mainEntity"]).to be_an(Array)
      expect(json["mainEntity"].size).to eq(2)
      expect(json["mainEntity"][0]["@type"]).to eq("Question")
      expect(json["mainEntity"][0]["acceptedAnswer"]["@type"]).to eq("Answer")
    end

    it "generates script tag" do
      faq = described_class.new
      faq.add_question(question: "What is SEO?", answer: "Search Engine Optimization")

      script_tag = faq.to_script_tag

      expect(script_tag).to include('<script type="application/ld+json">')
      expect(script_tag).to include('"@type": "FAQPage"')
      expect(script_tag).to include('"@type": "Question"')
      expect(script_tag).to include('"@type": "Answer"')
      expect(script_tag).to include('</script>')
    end
  end

  describe "complete example" do
    it "creates complete FAQ page with multiple questions" do
      faq = described_class.new
      faq.add_questions([
        {
          question: "What is Ruby on Rails?",
          answer: "Ruby on Rails is a server-side web application framework written in Ruby."
        },
        {
          question: "What are the benefits of using Rails?",
          answer: "Rails follows convention over configuration, has a large ecosystem, and enables rapid development."
        },
        {
          question: "Is Rails still relevant in 2024?",
          answer: "Yes, Rails continues to be a popular choice for web development with regular updates and a strong community."
        },
        {
          question: "What is ActiveRecord?",
          answer: "ActiveRecord is the ORM (Object-Relational Mapping) layer in Rails that connects classes to database tables."
        }
      ])

      hash = faq.to_h

      expect(hash["@type"]).to eq("FAQPage")
      expect(hash["mainEntity"]).to be_an(Array)
      expect(hash["mainEntity"].size).to eq(4)

      # Check first question structure
      first_q = hash["mainEntity"][0]
      expect(first_q["@type"]).to eq("Question")
      expect(first_q["name"]).to eq("What is Ruby on Rails?")
      expect(first_q["acceptedAnswer"]["@type"]).to eq("Answer")
      expect(first_q["acceptedAnswer"]["text"]).to include("server-side web application framework")

      # Check last question
      last_q = hash["mainEntity"][3]
      expect(last_q["name"]).to eq("What is ActiveRecord?")
      expect(last_q["acceptedAnswer"]["text"]).to include("ORM")
    end
  end
end
