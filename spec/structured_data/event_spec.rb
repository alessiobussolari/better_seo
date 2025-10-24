# frozen_string_literal: true

require "spec_helper"

RSpec.describe BetterSeo::StructuredData::Event do
  describe "initialization" do
    it "creates instance with @type Event" do
      event = described_class.new
      expect(event.to_h["@type"]).to eq("Event")
    end

    it "accepts hash initialization" do
      event = described_class.new(
        name: "Tech Conference 2024",
        startDate: "2024-06-15T09:00:00Z"
      )

      expect(event.to_h["name"]).to eq("Tech Conference 2024")
      expect(event.to_h["startDate"]).to eq("2024-06-15T09:00:00Z")
    end
  end

  describe "basic properties" do
    let(:event) { described_class.new }

    it "sets name" do
      event.name("Tech Conference 2024")
      expect(event.to_h["name"]).to eq("Tech Conference 2024")
    end

    it "sets description" do
      event.description("Annual tech conference")
      expect(event.to_h["description"]).to eq("Annual tech conference")
    end

    it "sets url" do
      event.url("https://techconf.com")
      expect(event.to_h["url"]).to eq("https://techconf.com")
    end

    it "sets image as string" do
      event.image("https://example.com/event.jpg")
      expect(event.to_h["image"]).to eq("https://example.com/event.jpg")
    end

    it "sets image as array" do
      event.image(["https://example.com/1.jpg", "https://example.com/2.jpg"])
      expect(event.to_h["image"]).to eq(["https://example.com/1.jpg", "https://example.com/2.jpg"])
    end
  end

  describe "date and time" do
    let(:event) { described_class.new }

    it "sets start date" do
      event.start_date("2024-06-15T09:00:00Z")
      expect(event.to_h["startDate"]).to eq("2024-06-15T09:00:00Z")
    end

    it "sets end date" do
      event.end_date("2024-06-15T17:00:00Z")
      expect(event.to_h["endDate"]).to eq("2024-06-15T17:00:00Z")
    end

    it "handles Date objects" do
      event.start_date(Date.new(2024, 6, 15))
      expect(event.to_h["startDate"]).to eq("2024-06-15")
    end

    it "handles Time objects" do
      time = Time.new(2024, 6, 15, 9, 0, 0, "+00:00")
      event.start_date(time)
      expect(event.to_h["startDate"]).to eq(time.iso8601)
    end

    it "handles DateTime objects" do
      datetime = DateTime.new(2024, 6, 15, 9, 0, 0, "+00:00")
      event.start_date(datetime)
      expect(event.to_h["startDate"]).to eq(datetime.iso8601)
    end
  end

  describe "event status" do
    let(:event) { described_class.new }

    it "sets event status" do
      event.event_status("EventScheduled")
      expect(event.to_h["eventStatus"]).to eq("https://schema.org/EventScheduled")
    end

    it "handles full schema.org URL" do
      event.event_status("https://schema.org/EventCancelled")
      expect(event.to_h["eventStatus"]).to eq("https://schema.org/EventCancelled")
    end

    it "supports EventScheduled" do
      event.event_status("EventScheduled")
      expect(event.to_h["eventStatus"]).to eq("https://schema.org/EventScheduled")
    end

    it "supports EventCancelled" do
      event.event_status("EventCancelled")
      expect(event.to_h["eventStatus"]).to eq("https://schema.org/EventCancelled")
    end

    it "supports EventPostponed" do
      event.event_status("EventPostponed")
      expect(event.to_h["eventStatus"]).to eq("https://schema.org/EventPostponed")
    end

    it "supports EventRescheduled" do
      event.event_status("EventRescheduled")
      expect(event.to_h["eventStatus"]).to eq("https://schema.org/EventRescheduled")
    end
  end

  describe "event attendance mode" do
    let(:event) { described_class.new }

    it "sets offline attendance mode" do
      event.event_attendance_mode("OfflineEventAttendanceMode")
      expect(event.to_h["eventAttendanceMode"]).to eq("https://schema.org/OfflineEventAttendanceMode")
    end

    it "sets online attendance mode" do
      event.event_attendance_mode("OnlineEventAttendanceMode")
      expect(event.to_h["eventAttendanceMode"]).to eq("https://schema.org/OnlineEventAttendanceMode")
    end

    it "sets mixed attendance mode" do
      event.event_attendance_mode("MixedEventAttendanceMode")
      expect(event.to_h["eventAttendanceMode"]).to eq("https://schema.org/MixedEventAttendanceMode")
    end
  end

  describe "location" do
    let(:event) { described_class.new }

    it "sets physical location with Place" do
      event.location(
        type: "Place",
        name: "Convention Center",
        address: {
          street: "123 Main St",
          city: "San Francisco",
          region: "CA",
          postal_code: "94105",
          country: "US"
        }
      )

      location = event.to_h["location"]
      expect(location["@type"]).to eq("Place")
      expect(location["name"]).to eq("Convention Center")
      expect(location["address"]["@type"]).to eq("PostalAddress")
      expect(location["address"]["addressLocality"]).to eq("San Francisco")
    end

    it "sets virtual location" do
      event.location(
        type: "VirtualLocation",
        url: "https://zoom.us/meeting/123"
      )

      location = event.to_h["location"]
      expect(location["@type"]).to eq("VirtualLocation")
      expect(location["url"]).to eq("https://zoom.us/meeting/123")
    end

    it "sets location with name only" do
      event.location(name: "Online Event")
      location = event.to_h["location"]
      expect(location["name"]).to eq("Online Event")
    end
  end

  describe "organizer" do
    let(:event) { described_class.new }

    it "sets organizer from hash" do
      event.organizer(
        type: "Organization",
        name: "Tech Events Inc",
        url: "https://techevents.com"
      )

      organizer = event.to_h["organizer"]
      expect(organizer["@type"]).to eq("Organization")
      expect(organizer["name"]).to eq("Tech Events Inc")
      expect(organizer["url"]).to eq("https://techevents.com")
    end

    it "sets organizer as Person" do
      event.organizer(
        type: "Person",
        name: "John Doe",
        email: "john@example.com"
      )

      organizer = event.to_h["organizer"]
      expect(organizer["@type"]).to eq("Person")
      expect(organizer["name"]).to eq("John Doe")
    end

    it "accepts structured data object" do
      org = BetterSeo::StructuredData::Organization.new(name: "Tech Events Inc")
      event.organizer(org)

      organizer = event.to_h["organizer"]
      expect(organizer["@type"]).to eq("Organization")
      expect(organizer["name"]).to eq("Tech Events Inc")
    end
  end

  describe "offers" do
    let(:event) { described_class.new }

    it "sets single offer" do
      event.offers(
        price: 299.99,
        price_currency: "USD",
        url: "https://techconf.com/tickets",
        availability: "InStock"
      )

      offer = event.to_h["offers"]
      expect(offer["@type"]).to eq("Offer")
      expect(offer["price"]).to eq(299.99)
      expect(offer["priceCurrency"]).to eq("USD")
      expect(offer["availability"]).to eq("https://schema.org/InStock")
    end

    it "sets multiple offers as array" do
      offers_array = [
        { price: 199.99, price_currency: "USD", name: "Early Bird" },
        { price: 299.99, price_currency: "USD", name: "Regular" }
      ]

      event.offers(offers_array)

      offers = event.to_h["offers"]
      expect(offers).to be_an(Array)
      expect(offers.size).to eq(2)
      expect(offers[0]["name"]).to eq("Early Bird")
      expect(offers[1]["name"]).to eq("Regular")
    end

    it "sets valid from and valid through dates" do
      event.offers(
        price: 299.99,
        price_currency: "USD",
        valid_from: "2024-01-01",
        valid_through: "2024-05-31"
      )

      offer = event.to_h["offers"]
      expect(offer["validFrom"]).to eq("2024-01-01")
      expect(offer["validThrough"]).to eq("2024-05-31")
    end
  end

  describe "performer" do
    let(:event) { described_class.new }

    it "sets performer from hash" do
      event.performer(
        type: "Person",
        name: "Jane Speaker"
      )

      performer = event.to_h["performer"]
      expect(performer["@type"]).to eq("Person")
      expect(performer["name"]).to eq("Jane Speaker")
    end

    it "sets multiple performers" do
      performers = [
        { type: "Person", name: "Speaker One" },
        { type: "Person", name: "Speaker Two" }
      ]

      event.performer(performers)

      performers_result = event.to_h["performer"]
      expect(performers_result).to be_an(Array)
      expect(performers_result.size).to eq(2)
    end
  end

  describe "method chaining" do
    it "supports fluent interface" do
      event = described_class.new
        .name("Tech Conference")
        .start_date("2024-06-15T09:00:00Z")
        .end_date("2024-06-15T17:00:00Z")

      expect(event.to_h["name"]).to eq("Tech Conference")
      expect(event.to_h["startDate"]).to eq("2024-06-15T09:00:00Z")
      expect(event.to_h["endDate"]).to eq("2024-06-15T17:00:00Z")
    end
  end

  describe "JSON-LD generation" do
    it "generates valid JSON-LD" do
      event = described_class.new
      event.name("Tech Conference 2024")
      event.start_date("2024-06-15T09:00:00Z")
      event.end_date("2024-06-15T17:00:00Z")
      event.location(
        type: "Place",
        name: "Convention Center",
        address: { city: "San Francisco" }
      )

      json = JSON.parse(event.to_json)

      expect(json["@context"]).to eq("https://schema.org")
      expect(json["@type"]).to eq("Event")
      expect(json["name"]).to eq("Tech Conference 2024")
      expect(json["location"]["@type"]).to eq("Place")
    end

    it "generates script tag" do
      event = described_class.new(name: "Tech Conference")
      script_tag = event.to_script_tag

      expect(script_tag).to include('<script type="application/ld+json">')
      expect(script_tag).to include('"@type": "Event"')
      expect(script_tag).to include('"name": "Tech Conference"')
      expect(script_tag).to include('</script>')
    end
  end

  describe "complete example" do
    it "creates complete event with all features" do
      event = described_class.new
      event.name("Tech Conference 2024: The Future of AI")
      event.description("Join us for the premier AI conference")
      event.url("https://techconf.com/2024")
      event.image([
        "https://techconf.com/images/event-banner.jpg",
        "https://techconf.com/images/venue.jpg"
      ])
      event.start_date("2024-06-15T09:00:00-07:00")
      event.end_date("2024-06-17T17:00:00-07:00")
      event.event_status("EventScheduled")
      event.event_attendance_mode("MixedEventAttendanceMode")
      event.location(
        type: "Place",
        name: "San Francisco Convention Center",
        address: {
          street: "747 Howard St",
          city: "San Francisco",
          region: "CA",
          postal_code: "94103",
          country: "US"
        }
      )
      event.organizer(
        type: "Organization",
        name: "Tech Events Global",
        url: "https://techeventsglobal.com"
      )
      event.offers([
        {
          name: "Early Bird Ticket",
          price: 299.99,
          price_currency: "USD",
          valid_from: "2024-01-01",
          valid_through: "2024-03-31",
          availability: "InStock"
        },
        {
          name: "Regular Ticket",
          price: 499.99,
          price_currency: "USD",
          valid_from: "2024-04-01",
          availability: "InStock"
        }
      ])

      hash = event.to_h

      expect(hash["@type"]).to eq("Event")
      expect(hash["name"]).to eq("Tech Conference 2024: The Future of AI")
      expect(hash["eventStatus"]).to eq("https://schema.org/EventScheduled")
      expect(hash["eventAttendanceMode"]).to eq("https://schema.org/MixedEventAttendanceMode")
      expect(hash["location"]["@type"]).to eq("Place")
      expect(hash["organizer"]["@type"]).to eq("Organization")
      expect(hash["offers"]).to be_an(Array)
      expect(hash["offers"].size).to eq(2)
      expect(hash["image"]).to be_an(Array)
    end
  end
end
