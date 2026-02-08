# frozen_string_literal: true

require_relative "support/api"
require_relative "support/calendar_writer"

module EsportIcs
  module Games
    class Base
      ICS_PATH = "ics/:folder/:team.ics"

      attr_reader :calendars, :api_code, :folder

      def initialize(api_code:, ics_folder:)
        @api_code = api_code
        @folder = ics_folder
        @calendars = {}
      end

      def build!
        Api.new(game_code: @api_code)
          .fetch_matches!
          .matches
          .each { |match| process_match(match) }

        self
      end

      def write!
        writer = CalendarWriter.new

        @calendars.each do |team_slug, calendar|
          file_path = ICS_PATH.sub(":folder", @folder).sub(":team", team_slug)
          writer.write(file_path, calendar)
        end

        self
      end

      private

      def process_match(match)
        event = match.to_event

        match.teams.each do |team|
          team_calendar = @calendars[team.slug] ||= team.to_ical
          team_calendar.add_event(event)
        end
      end
    end
  end
end
