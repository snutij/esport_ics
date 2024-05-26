# frozen_string_literal: true

require "test_helper"

class EsportIcsTest < Minitest::Test
  EXPECTATIONS_PATH = File.expand_path("expectations", __dir__)
  FIXTURES_PATH = File.expand_path("fixtures", __dir__)
  LEAGUE_OF_LEGENDS_FIXTURES_PATH = File.join(FIXTURES_PATH, "league_of_legends", "mock.json")

  def test_generate_league_of_legends_ics
    Net::HTTP.stub(:get_response, FakeHTTPResponse.new(200, JSON.parse(
      File.read(LEAGUE_OF_LEGENDS_FIXTURES_PATH).to_json,
    ))) do
      calendars = EsportIcs::LeagueOfLegends.generate_calendars
      calendars.each do |calendar|
        expected = File.read(File.join(
          EXPECTATIONS_PATH,
          "league_of_legends",
          "#{calendar.custom_property("code").first}.ics",
        ))
        result = calendar.to_ical

        assert_equal(
          expected,
          result.gsub(/^UID:.*\r\n(?: .*\r\n)*/, "").gsub(/^DTSTAMP:.*\r\n(?: .*\r\n)*/, ""),
        )
      end

      assert_equal(5, calendars.length)
    end
  end
end
