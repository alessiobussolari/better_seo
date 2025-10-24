# frozen_string_literal: true

module BetterSeo
  module StructuredData
    class Event < Base
      EVENT_STATUS_MAPPING = {
        "EventScheduled" => "https://schema.org/EventScheduled",
        "EventCancelled" => "https://schema.org/EventCancelled",
        "EventPostponed" => "https://schema.org/EventPostponed",
        "EventRescheduled" => "https://schema.org/EventRescheduled"
      }.freeze

      ATTENDANCE_MODE_MAPPING = {
        "OfflineEventAttendanceMode" => "https://schema.org/OfflineEventAttendanceMode",
        "OnlineEventAttendanceMode" => "https://schema.org/OnlineEventAttendanceMode",
        "MixedEventAttendanceMode" => "https://schema.org/MixedEventAttendanceMode"
      }.freeze

      AVAILABILITY_MAPPING = {
        "InStock" => "https://schema.org/InStock",
        "SoldOut" => "https://schema.org/SoldOut",
        "PreOrder" => "https://schema.org/PreOrder"
      }.freeze

      def initialize(**properties)
        super("Event", **properties)
      end

      # Basic properties
      def name(value)
        set(:name, value)
      end

      def description(value)
        set(:description, value)
      end

      def url(value)
        set(:url, value)
      end

      def image(value)
        set(:image, value)
      end

      # Date and time
      def start_date(value)
        formatted_value = format_date(value)
        set(:startDate, formatted_value)
      end

      def end_date(value)
        formatted_value = format_date(value)
        set(:endDate, formatted_value)
      end

      # Event status
      def event_status(value)
        status_value = if value.start_with?("https://schema.org/")
                         value
                       else
                         EVENT_STATUS_MAPPING[value] || value
                       end
        set(:eventStatus, status_value)
      end

      # Event attendance mode
      def event_attendance_mode(value)
        mode_value = if value.start_with?("https://schema.org/")
                       value
                     else
                       ATTENDANCE_MODE_MAPPING[value] || value
                     end
        set(:eventAttendanceMode, mode_value)
      end

      # Location (Place or VirtualLocation)
      def location(type: nil, name: nil, address: nil, url: nil, **other_properties)
        location_hash = {}

        location_hash["@type"] = type if type
        location_hash["name"] = name if name
        location_hash["url"] = url if url

        if address
          location_hash["address"] = build_address(address)
        end

        other_properties.each do |key, value|
          location_hash[key.to_s] = value
        end

        set(:location, location_hash)
      end

      # Organizer (Organization or Person)
      def organizer(value)
        organizer_value = if value.is_a?(Base)
                            value
                          elsif value.is_a?(Hash)
                            build_organizer(value)
                          else
                            value
                          end

        set(:organizer, organizer_value)
      end

      # Offers
      def offers(value)
        if value.is_a?(Array)
          set(:offers, value.map { |v| build_offer(v) })
        elsif value.is_a?(Hash)
          set(:offers, build_offer(value))
        else
          set(:offers, value)
        end
      end

      # Performer
      def performer(value)
        if value.is_a?(Array)
          set(:performer, value.map { |v| build_performer(v) })
        elsif value.is_a?(Hash)
          set(:performer, build_performer(value))
        else
          set(:performer, value)
        end
      end

      private

      def format_date(value)
        case value
        when Date
          value.to_s
        when Time, DateTime
          value.iso8601
        else
          value
        end
      end

      def build_address(address)
        return address unless address.is_a?(Hash)

        address_hash = {
          "@type" => "PostalAddress"
        }

        address_hash["streetAddress"] = address[:street] if address[:street]
        address_hash["addressLocality"] = address[:city] if address[:city]
        address_hash["addressRegion"] = address[:region] if address[:region]
        address_hash["postalCode"] = address[:postal_code] if address[:postal_code]
        address_hash["addressCountry"] = address[:country] if address[:country]

        address_hash
      end

      def build_organizer(hash)
        organizer = {
          "@type" => hash[:type] || "Organization"
        }

        organizer["name"] = hash[:name] if hash[:name]
        organizer["url"] = hash[:url] if hash[:url]
        organizer["email"] = hash[:email] if hash[:email]

        organizer
      end

      def build_offer(hash)
        offer = {
          "@type" => "Offer"
        }

        offer["name"] = hash[:name] if hash[:name]
        offer["price"] = hash[:price] if hash[:price]
        offer["priceCurrency"] = hash[:price_currency] if hash[:price_currency]
        offer["url"] = hash[:url] if hash[:url]
        offer["validFrom"] = hash[:valid_from] if hash[:valid_from]
        offer["validThrough"] = hash[:valid_through] if hash[:valid_through]

        if hash[:availability]
          offer["availability"] = if hash[:availability].start_with?("https://")
                                    hash[:availability]
                                  else
                                    AVAILABILITY_MAPPING[hash[:availability]] || hash[:availability]
                                  end
        end

        offer
      end

      def build_performer(hash)
        performer = {
          "@type" => hash[:type] || "Person"
        }

        performer["name"] = hash[:name] if hash[:name]
        performer["url"] = hash[:url] if hash[:url]

        performer
      end
    end
  end
end
