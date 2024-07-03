# frozen_string_literal: true

module EsportIcs
  module LeagueOfLegends
    class Generator
      GAME_SLUG = "league_of_legends"
      TEAM_ICS_PATH = "ics/#{GAME_SLUG}/:team_slug.ics"

      attr_reader :calendars

      def initialize
        @calendars = {}
      end

      def generate
        Api.new(game_slug: GAME_SLUG).fetch_matches!.matches.each { |match| process_match(match) }
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
        event = match.to_event

        match.teams.each do |team|
          team_calendar = calendars[team.slug] ||= team.to_ical
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
