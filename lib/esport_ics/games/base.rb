# frozen_string_literal: true

require_relative "support/api"

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
        @calendars.each do |team_slug, calendar|
          file_path = ICS_PATH.sub(":folder", @folder).sub(":team", team_slug)
          write_calendar_to_file(file_path, calendar)
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

      def write_calendar_to_file(file_path, calendar)
        dir_path = File.dirname(file_path)
        FileUtils.mkdir_p(dir_path) unless Dir.exist?(dir_path)

        existing_events = read_existing_events(file_path)
        merged_events = merge_events(existing_events, calendar)

        merged_calendar = Icalendar::Calendar.new
        calendar.custom_properties.each { |key, value| merged_calendar.append_custom_property(key, value.first) }
        merged_calendar.publish

        merged_events.values
          .sort_by { |e| e.dtstart.to_time }
          .each { |event| merged_calendar.add_event(event) }

        File.open(file_path, "w+") do |file|
          file.write(merged_calendar.to_ical)
        end
      end

      def read_existing_events(file_path)
        return {} unless File.exist?(file_path)

        calendars = Icalendar::Calendar.parse(File.read(file_path))
        return {} if calendars.nil? || calendars.empty?

        calendars.first.events.each_with_object({}) do |event, hash|
          hash[event.uid.to_s] = event
        end
      rescue StandardError
        {}
      end

      def merge_events(existing_events, new_calendar)
        new_events_by_uid = new_calendar.events.each_with_object({}) do |event, hash|
          hash[event.uid.to_s] = event
        end

        existing_events
          .reject { |uid, _| new_events_by_uid.key?(uid) }
          .merge(new_events_by_uid)
      end
    end
  end
end
