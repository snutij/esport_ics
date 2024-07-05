# frozen_string_literal: true

require "test_helper"

module EsportIcs
  module Games
    class CounterStrikeTest < Minitest::Test
      def setup
        @game = CounterStrike.new
      end

      def test_create_ics
        expected_ics = Dir.glob(File.join(EXPECTATIONS_PATH, @game.folder, "*.ics")).map { |f| File.read(f) }

        stub_matches_league(@game.api_code, @game.folder) do
          calendars = @game.build!.calendars.values.map(&:to_ical)

          assert_equal(calendars.size, expected_ics.size)

          calendars.concat(expected_ics).map { |c| Icalendar::Calendar.parse(c).first }
            .group_by { |c| c.custom_property("slug").first }
            .each { |_slug, (cal, exp)| assert_same_calendar(cal, exp) }
        end
      end
    end
  end
end
