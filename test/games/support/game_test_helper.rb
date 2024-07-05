# frozen_string_literal: true

module EsportIcs
  module Games
    module GameTestHelper
      FIXTURES_DIR = "test/fixtures"
      EXPECTATIONS_DIR = "test/expectations"

      class << self
        def included(base)
          base.class_eval do
            def test_create_ics
              expected_ics = Dir.glob(File.join(EXPECTATIONS_DIR, @game.folder, "*.ics")).map do |f|
                File.read(f)
              end

              with_matches_stubbed do
                calendars = @game.build!.calendars.values.map(&:to_ical)

                assert_equal(calendars.size, expected_ics.size)

                calendars.concat(expected_ics).map { |c| Icalendar::Calendar.parse(c).first }
                  .group_by { |c| c.custom_property("slug").first }
                  .each { |_slug, (cal, exp)| assert_same_calendar(cal, exp) }
              end
            end

            def with_matches_stubbed
              mock_matches = File.read(File.join(FIXTURES_DIR, @game.folder, "matches.json"))

              stub_request(:get, Api.new(game_code: @game.api_code).matches_url)
                .with(query: { "page[size]": 100, "page[number]": 1 })
                .to_return_json(body: JSON.parse(mock_matches).to_json)

              stub_request(:get, Api.new(game_code: @game.api_code).matches_url)
                .with(query: { "page[size]": 100, "page[number]": 2 })
                .to_return_json(body: [].to_json)

              yield
            end
          end
        end
      end

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
    end
  end
end
