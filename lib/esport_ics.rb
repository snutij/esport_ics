# frozen_string_literal: true

require "json"
require "net/http"
require "icalendar"

module EsportIcs
  class Error < StandardError; end

  # handle the generation of ics files for all League of Legends leagues
  module LeagueOfLegends
    LFL_LEAGUE_ID = "74452834262590"
    LEC_LEAGUE_ID = "97530759608318"
    EMEA_MASTERS_LEAGUE_ID = "51200282806521"
    LCS_LEAGUE_ID = "34247741770488"
    LPL_LEAGUE_ID = "31698836969528"
    LCK_LEAGUE_ID = "97692597116075"
    LFL_DIV2_LEAGUE_ID = "72652091833775"
    MSI_LEAGUE_ID = "69220076243247"
    WORLDS_LEAGUE_ID = "50606172015690"

    ALL_LEAGUES = [
      LFL_LEAGUE_ID,
      LEC_LEAGUE_ID,
      EMEA_MASTERS_LEAGUE_ID,
      LCS_LEAGUE_ID,
      LPL_LEAGUE_ID,
      LCK_LEAGUE_ID,
      LFL_DIV2_LEAGUE_ID,
      MSI_LEAGUE_ID,
      WORLDS_LEAGUE_ID,
    ].freeze

    Match = Struct.new(:id, :name, :startTime, :endTime, :teams, :league, keyword_init: true)
    Team = Struct.new(:id, :name, :code, keyword_init: true)
    League = Struct.new(:id, :name, :code, keyword_init: true)

    class << self
      def generate_calendars
        uri = URI("https://api.teamswap.io/api/v2/lol/leagues/schedule")
        events = []
        page = 0
        max = 100
        loop do
          params = { page: page, league: ALL_LEAGUES }
          uri.query = URI.encode_www_form(params)
          response = Net::HTTP.get_response(uri)

          break unless response.code == 200

          body = JSON.parse(response.body)
          events.concat(body.fetch("data", []))

          break if body.empty? || events.length >= max || page >= 10

          page += 1
        end

        return if events.none?

        matches = events.map do |event|
          Match.new(
            id: event.fetch("id"),
            name: event.fetch("name"),
            startTime: Time.strptime(Time.parse(event.fetch("scheduledAt")).to_s, "%Y-%m-%d %H:%M:%S"),
            endTime: Time.strptime((Time.parse(event.fetch("scheduledAt")) + (60 * 60)).to_s, "%Y-%m-%d %H:%M:%S"),
            teams: event.fetch("teams").map do |team|
              Team.new(
                id: team.fetch("id"),
                name: team.fetch("name"),
                code: team.fetch("code"),
              )
            end,
            league: League.new(
              id: event.fetch("league").fetch("id"),
              name: event.fetch("league").fetch("name"),
              code: event.fetch("league").fetch("code"),
            ),
          )
        end

        calendars = matches.map(&:league).uniq.map do |league|
          cal = Icalendar::Calendar.new
          cal.append_custom_property("name", league.name)
          cal.append_custom_property("description", "#{league.name} games schedule")
          cal.append_custom_property("code", league.code)
          cal.append_custom_property("id", league.id.to_s)
          cal
        end

        all_league_cal = Icalendar::Calendar.new
        all_league_cal.append_custom_property("name", "All Leagues")
        all_league_cal.append_custom_property("description", "All Leagues games schedule")
        all_league_cal.append_custom_property("id", "all")
        all_league_cal.append_custom_property("code", "all")

        matches.each do |game|
          event = Icalendar::Event.new
          event.dtstart = Icalendar::Values::DateTime.new(game.startTime, "tzid" => "UTC")
          event.dtend = Icalendar::Values::DateTime.new(game.endTime, "tzid" => "UTC")
          event.summary = game.name
          event.description = "[#{game.league.name}] - #{game.teams.map(&:name).join(" vs ")}"
          event.ip_class = "PUBLIC"
          all_league_cal.add_event(event)
          calendars.find { |c| c.custom_property("id").first == game.league.id.to_s }.add_event(event)
        end

        calendars << all_league_cal

        calendars.each(&:publish)

        calendars
      end

      def write_ics(calendars)
        calendars.each do |cal|
          File.write("ics/league_of_legends/#{cal.custom_property("code").first}.ics", cal.to_ical)
        end
      end
    end
  end
end
