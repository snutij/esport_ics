# frozen_string_literal: true

require_relative "../api"

module EsportIcs
  module Games
    class Base
      ICS_PATH = "ics/:game_slug/:team_slug.ics"

      attr_reader :calendars

      def initialize
        @calendars = {}
      end

      def generate
        Api.new(game_slug: api_slug).fetch_matches!.matches.each { |match| process_match(match) }
        self
      end

      def write!
        @calendars.each do |team_slug, calendar|
          file_path = ICS_PATH.sub(":game_slug", path_slug).sub(":team_slug", team_slug)
          write_calendar_to_file(file_path, calendar)
        end
      end

      def api_slug
        raise NotImplementedError, "#{self.class} class must define 'api_slug'"
      end

      def path_slug
        raise NotImplementedError, "#{self.class} class must define 'path_slug'"
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
