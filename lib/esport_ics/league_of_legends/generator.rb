# frozen_string_literal: true

require_relative "fetcher"
require_relative "mapper"

module EsportIcs
  module LeagueOfLegends
    class Generator
      LEAGUE_ICS_PATH = "ics/league_of_legends/:league_slug/all.ics"
      TEAM_ICS_PATH = "ics/league_of_legends/:league_slug/:team_slug.ics"

      attr_reader :calendars

      def initialize
        @calendars = []
      end

      def generate
        Fetcher.fetch_leagues!.each do |league|
          matches = Fetcher.fetch_matches!(league.id)
          next if matches.empty?

          @calendars << process_league(league, matches)
        end
        self
      end

      def write!
        @calendars.each do |calendar|
          write_league_calendar(calendar[:league])
          write_team_calendars(calendar[:teams], calendar[:league].custom_property("slug").first)
        end
      end

      private

      def process_league(league, matches)
        league_calendar = Mapper.to_ical(league)
        team_calendars = {}

        matches.each do |match|
          event = Mapper.to_event(match)
          league_calendar.add_event(event)

          match.teams.each do |team|
            team_calendar = team_calendars[team.slug] ||= Mapper.to_ical(team)
            team_calendar.add_event(event)
          end
        end

        { league: league_calendar, teams: team_calendars }
      end

      def write_league_calendar(league_calendar)
        file_path = LEAGUE_ICS_PATH.sub(":league_slug", league_calendar.custom_property("slug").first)
        write_calendar_to_file(file_path, league_calendar)
      end

      def write_team_calendars(team_calendars, league_slug)
        team_calendars.each do |team_slug, team_calendar|
          file_path = TEAM_ICS_PATH.sub(":league_slug", league_slug).sub(":team_slug", team_slug)
          write_calendar_to_file(file_path, team_calendar)
        end
      end

      def write_calendar_to_file(file_path, calendar)
        dir_path = File.dirname(file_path)
        FileUtils.mkdir_p(dir_path) unless Dir.exist?(dir_path)

        File.open(file_path, "w+") do |file|
          file.write(calendar.to_ical)
        end
      end
    end
  end
end
