# frozen_string_literal: true

require "test_helper"

module EsportIcs
  module LeagueOfLegends
    class GeneratorTest < Minitest::Test
      MOCK_LEAGUE = File.read(File.join(FIXTURES_PATH, "league_of_legends", "leagues.json"))
      MOCK_MATCHES = File.read(File.join(FIXTURES_PATH, "league_of_legends", "matches.json"))
      EXPECTED_ICS = Dir.glob(File.join(EXPECTATIONS_PATH, "league_of_legends", "*.ics")).map { |f| File.read(f) }

      def test_create_ics
        with_api_stubs do
          Generator.new.calendars.concat(EXPECTED_ICS)
            .map { |c| Icalendar::Calendar.parse(c).first }
            .group_by { |c| c.custom_property("slug").first }
            .each { |_slug, (cal, exp)| assert_same_calendar(cal, exp) }
        end
      end

      private

      def assert_same_calendar(calendar, expected_ics)
        assert(calendar)
        assert(expected_ics)

        assert_equal(calendar.ip_name, expected_ics.ip_name)
        assert_equal(calendar.custom_property("slug"), expected_ics.custom_property("slug"))
        assert_equal(calendar.ip_method, expected_ics.ip_method)
        assert_equal(calendar.events.size, expected_ics.events.size)

        calendar.events.zip(expected_ics.events).each do |event, expected_event|
          assert_equal(event.summary, expected_event.summary)
          assert_equal(event.description, expected_event.description)
          assert_equal(event.ip_class, expected_event.ip_class)
          assert_equal(event.dtstart.ical_params["tzid"], expected_event.dtstart.ical_params["tzid"])
          assert_equal(event.dtend.ical_params["tzid"], expected_event.dtend.ical_params["tzid"])
        end
      end

      def with_api_stubs
        stub_leagues

        JSON.parse(MOCK_LEAGUE)
          .map { |league| Mapper.to_leagues!(league) }
          .each { |league| stub_matches_league(league.id) }

        yield
      end

      def stub_leagues
        stub_request(
          :get,
          "#{Fetcher::LEAGUE_PATH}?page[size]=100",
        ).to_return_json(body: MOCK_LEAGUE)
      end

      def stub_matches_league(league_id)
        stub_request(
          :get,
          "#{Fetcher::MATCHES_PATH}?filter[league_id]=#{league_id}",
        ).to_return_json(body: JSON.parse(MOCK_MATCHES).filter { |match| match["league_id"] == league_id }.to_json)
      end
    end
  end
end
