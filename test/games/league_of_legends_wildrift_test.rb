# frozen_string_literal: true

require "test_helper"

module EsportIcs
  module Games
    class LeagueOfLegendsWildRiftTest < Minitest::Test
      EXPECTED_ICS = Dir.glob(File.join(EXPECTATIONS_PATH, "league_of_legends_wildrift", "*.ics")).map do |f|
        File.read(f)
      end

      def test_create_ics
        stub_matches_league(LeagueOfLegendsWildRift::API_SLUG, LeagueOfLegendsWildRift::PATH_SLUG) do
          calendars = LeagueOfLegendsWildRift.new.generate.calendars.values.map(&:to_ical)

          assert_equal(calendars.size, EXPECTED_ICS.size)

          calendars.concat(EXPECTED_ICS).map { |c| Icalendar::Calendar.parse(c).first }
            .group_by { |c| c.custom_property("slug").first }
            .each { |_slug, (cal, exp)| assert_same_calendar(cal, exp) }
        end
      end
    end
  end
end
