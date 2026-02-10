# frozen_string_literal: true

require "test_helper"

module EsportIcs
  class MatchTest < Minitest::Test
    def build_api_match(overrides = {})
      {
        "id" => 12345,
        "name" => "Team A vs Team B",
        "scheduled_at" => "2024-06-15T18:00:00Z",
        "number_of_games" => 1,
        "opponents" => [
          { "opponent" => { "name" => "Team A" } },
          { "opponent" => { "name" => "Team B" } },
        ],
        "league" => { "name" => "LEC" },
        "serie" => { "full_name" => "Summer 2024" },
        "tournament" => { "name" => "Regular Season" },
        "streams_list" => [
          { "main" => true, "official" => true, "raw_url" => "https://twitch.tv/lec" },
          { "main" => false, "official" => true, "raw_url" => "https://twitch.tv/lec2" },
        ],
      }.merge(overrides)
    end

    # --- Duration ---

    def test_bo1_duration_45_minutes
      match = Match.new(build_api_match("number_of_games" => 1))
      event = match.to_event

      assert_equal(2700, event.dtend.to_time - event.dtstart.to_time)
    end

    def test_bo3_duration_135_minutes
      match = Match.new(build_api_match("number_of_games" => 3))
      event = match.to_event

      assert_equal(8100, event.dtend.to_time - event.dtstart.to_time)
    end

    def test_bo5_duration_225_minutes
      match = Match.new(build_api_match("number_of_games" => 5))
      event = match.to_event

      assert_equal(13500, event.dtend.to_time - event.dtstart.to_time)
    end

    def test_nil_number_of_games_defaults_to_1
      match = Match.new(build_api_match("number_of_games" => nil))
      event = match.to_event

      assert_equal(2700, event.dtend.to_time - event.dtstart.to_time)
    end

    def test_zero_number_of_games_defaults_to_1
      match = Match.new(build_api_match("number_of_games" => 0))
      event = match.to_event

      assert_equal(2700, event.dtend.to_time - event.dtstart.to_time)
    end

    # --- Context ---

    def test_context_joins_league_serie_tournament
      match = Match.new(build_api_match)
      event = match.to_event

      assert_includes(event.description.to_s, "LEC - Summer 2024 - Regular Season")
    end

    def test_context_handles_nil_parts
      match = Match.new(build_api_match("league" => nil, "serie" => nil))
      event = match.to_event

      assert_includes(event.description.to_s, "Regular Season")
      refute_includes(event.description.to_s, " - - ")
    end

    def test_context_handles_empty_names
      match = Match.new(build_api_match(
        "league" => { "name" => "" },
        "serie" => { "full_name" => "Summer 2024" },
        "tournament" => { "name" => "Playoffs" },
      ))
      event = match.to_event

      assert_includes(event.description.to_s, "Summer 2024 - Playoffs")
      refute_match(/\A - /, event.description.to_s)
    end

    # --- Stream URL ---

    def test_stream_url_picks_main_and_official
      match = Match.new(build_api_match)
      event = match.to_event

      assert_equal("https://twitch.tv/lec", event.url.to_s)
    end

    def test_stream_url_nil_when_no_main_official
      match = Match.new(build_api_match("streams_list" => [
        { "main" => false, "official" => true, "raw_url" => "https://twitch.tv/lec" },
      ]))
      event = match.to_event

      assert_empty(event.url.to_a)
    end

    def test_stream_url_nil_when_streams_list_absent
      match = Match.new(build_api_match.tap { |m| m.delete("streams_list") })
      event = match.to_event

      assert_empty(event.url.to_a)
    end

    def test_stream_url_nil_when_streams_list_nil
      match = Match.new(build_api_match("streams_list" => nil))
      event = match.to_event

      assert_empty(event.url.to_a)
    end

    # --- to_event ---

    def test_to_event_uid_format
      match = Match.new(build_api_match)
      event = match.to_event

      assert_equal("pandascore-match-12345@esport-ics", event.uid.to_s)
    end

    def test_to_event_summary
      match = Match.new(build_api_match)
      event = match.to_event

      assert_equal("Team A vs Team B", event.summary.to_s)
    end

    def test_to_event_dtstart_utc
      match = Match.new(build_api_match)
      event = match.to_event

      assert_equal(Time.utc(2024, 6, 15, 18, 0, 0), event.dtstart.to_time)
    end

    def test_to_event_ip_class_public
      match = Match.new(build_api_match)
      event = match.to_event

      assert_equal("PUBLIC", event.ip_class.to_s)
    end

    def test_to_event_description_with_stream
      match = Match.new(build_api_match)
      event = match.to_event

      assert_includes(event.description.to_s, "Watch: https://twitch.tv/lec")
    end

    def test_to_event_description_without_stream
      match = Match.new(build_api_match("streams_list" => nil))
      event = match.to_event

      refute_includes(event.description.to_s, "Watch:")
    end

    def test_to_event_no_description_when_no_context_and_no_stream
      match = Match.new(build_api_match(
        "league" => nil, "serie" => nil, "tournament" => nil, "streams_list" => nil,
      ))
      event = match.to_event

      assert_empty(event.description.to_a)
    end

    # --- Teams ---

    def test_teams_extracted_from_opponents
      match = Match.new(build_api_match)

      assert_equal(2, match.teams.size)
      assert_equal("team-a", match.teams[0].slug)
      assert_equal("team-b", match.teams[1].slug)
    end
  end
end
