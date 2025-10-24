# frozen_string_literal: true

module BetterSeo
  module StructuredData
    class HowTo < Base
      attr_reader :steps

      def initialize(**properties)
        super("HowTo", **properties)
        @steps = []
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

      def total_time(value)
        set(:totalTime, value)
      end

      def supply(value)
        set(:supply, value)
      end

      def tool(value)
        set(:tool, value)
      end

      # Add a single step
      def add_step(name:, text:, image: nil, url: nil, position: nil)
        position ||= @steps.size + 1
        @steps << {
          name: name,
          text: text,
          image: image,
          url: url,
          position: position
        }
        self
      end

      # Add multiple steps from an array
      def add_steps(steps_array)
        steps_array.each do |step|
          add_step(
            name: step[:name],
            text: step[:text],
            image: step[:image],
            url: step[:url],
            position: step[:position]
          )
        end
        self
      end

      # Clear all steps
      def clear
        @steps = []
        @properties.delete(:step)
        self
      end

      # Override to_h to include steps
      def to_h
        hash = super

        if @steps.any?
          hash["step"] = @steps.map do |step|
            step_hash = {
              "@type" => "HowToStep",
              "name" => step[:name],
              "text" => step[:text],
              "position" => step[:position]
            }

            step_hash["image"] = step[:image] if step[:image]
            step_hash["url"] = step[:url] if step[:url]

            step_hash
          end
        end

        hash
      end
    end
  end
end
