# frozen_string_literal: true

require "test_helper"

module EsportIcs
  module Games
    class Dota2Test < Minitest::Test
      EXPECTED_ICS = Dir.glob(File.join(EXPECTATIONS_PATH, "dota_2", "*.ics")).map { |f| File.read(f) }

      def test_create_ics
        stub_matches_league(Dota2::API_SLUG, Dota2::PATH_SLUG) do
          calendars = Dota2.new.generate.calendars.values.map(&:to_ical)

          assert_equal(calendars.size, EXPECTED_ICS.size)

          calendars.concat(EXPECTED_ICS).map { |c| Icalendar::Calendar.parse(c).first }
            .group_by { |c| c.custom_property("slug").first }
            .each { |_slug, (cal, exp)| assert_same_calendar(cal, exp) }
        end
      end
    end
  end
end