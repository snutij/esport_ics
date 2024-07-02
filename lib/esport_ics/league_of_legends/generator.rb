# frozen_string_literal: true

require_relative "fetcher"
require_relative "mapper"

module EsportIcs
  module LeagueOfLegends
    class Generator
      TEAM_ICS_PATH = "ics/league_of_legends/:team_slug.ics"

      attr_reader :calendars

      def initialize
        @calendars = {}
      end

      def generate
        Fetcher.fetch_matches!.each { |match| process_match(match) }
        self
      end

      def write!
        @calendars.each do |team_slug, calendar|
          file_path = TEAM_ICS_PATH.sub(":team_slug", team_slug)
          write_calendar_to_file(file_path, calendar)
        end
      end

      private

      def process_match(match)
        event = Mapper.to_event(match)

        match.teams.each do |team|
          team_calendar = calendars[team.slug] ||= Mapper.to_ical(team)
          team_calendar.add_event(event)
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
