# frozen_string_literal: true

require "test_helper"

module EsportIcs
  module Valorant
    class GeneratorTest < Minitest::Test
      MOCK_MATCHES = File.read(File.join(FIXTURES_PATH, "valorant", "matches.json"))
      EXPECTED_ICS = Dir.glob(File.join(EXPECTATIONS_PATH, "valorant", "*.ics")).map { |f| File.read(f) }

      def test_create_ics
        stub_matches_league do
          calendars = Generator.new.generate.calendars.values.map(&:to_ical)

          assert_equal(calendars.size, EXPECTED_ICS.size)

          calendars.concat(EXPECTED_ICS).map { |c| Icalendar::Calendar.parse(c).first }
            .group_by { |c| c.custom_property("slug").first }
            .each { |_slug, (cal, exp)| assert_same_calendar(cal, exp) }
        end
      end

      private

      def assert_same_calendar(calendar, expected_ics)
        assert(calendar)
        assert(expected_ics)

        assert_equal(calendar.custom_property("name"), expected_ics.custom_property("name"))
        assert_equal(calendar.custom_property("slug"), expected_ics.custom_property("slug"))
        assert_equal(calendar.ip_name, expected_ics.ip_name)
        assert_equal(calendar.ip_method, expected_ics.ip_method)
        assert_equal(calendar.events.size, expected_ics.events.size)

        calendar.events.zip(expected_ics.events).each do |event, expected_event|
          assert_equal(event.summary, expected_event.summary)
          assert_equal(event.ip_class, expected_event.ip_class)
          assert_equal(event.dtstart.to_s, expected_event.dtstart.to_s)
          assert_equal(event.dtend.to_s, expected_event.dtend.to_s)
        end
      end

      def stub_matches_league
        stub_request(
          :get,
          "#{Fetcher::MATCHES_PATH}?page[size]=100&page[number]=1",
        ).to_return_json(body: JSON.parse(MOCK_MATCHES).to_json)

        stub_request(
          :get,
          "#{Fetcher::MATCHES_PATH}?page[size]=100&page[number]=2",
        ).to_return_json(body: [].to_json)
        yield
      end
    end
  end
end
