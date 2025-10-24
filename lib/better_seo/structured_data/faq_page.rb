# frozen_string_literal: true

module BetterSeo
  module StructuredData
    class FAQPage < Base
      attr_reader :questions

      def initialize(**properties)
        super("FAQPage", **properties)
        @questions = []
      end

      # Add a single question
      def add_question(question:, answer:)
        @questions << { question: question, answer: answer }
        self
      end

      # Add multiple questions from an array
      def add_questions(questions_array)
        questions_array.each do |q|
          add_question(question: q[:question], answer: q[:answer])
        end
        self
      end

      # Clear all questions
      def clear
        @questions = []
        @properties.delete(:mainEntity)
        self
      end

      # Override to_h to include mainEntity
      def to_h
        hash = super

        if @questions.any?
          hash["mainEntity"] = @questions.map do |q|
            {
              "@type" => "Question",
              "name" => q[:question],
              "acceptedAnswer" => {
                "@type" => "Answer",
                "text" => q[:answer]
              }
            }
          end
        end

        hash
      end
    end
  end
end
