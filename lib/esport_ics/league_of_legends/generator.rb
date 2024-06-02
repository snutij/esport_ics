# frozen_string_literal: true

require_relative "fetcher"

module EsportIcs
  module LeagueOfLegends
    class Generator
      ICS_PATH = "ics/league_of_legends/:slug.ics"

      attr_reader :calendars

      def initialize
        @calendars = create_calendars
      end

      def write!
        @calendars.each do |calendar|
          File.open(ICS_PATH.sub(":slug", calendar.custom_property("slug").first), "w+") do |file|
            file.write(calendar)
          end
        end
      end

      private

      def create_calendars
        leagues = Fetcher.fetch_leagues!
        return if leagues.none?

        calendars = []

        leagues.each do |league|
          matches = Fetcher.fetch_matches!(league.id)
          next if matches.none?

          calendar = calendar_for(league)

          matches.each do |match|
            event = calendar_event_for(match)
            calendar.add_event(event)
          end

          calendars << calendar.to_ical
        end

        calendars
      end

      def calendar_for(league)
        cal = Icalendar::Calendar.new
        cal.append_custom_property("name", league.name)
        cal.append_custom_property("slug", league.slug)
        cal.publish
        cal
      end

      def calendar_event_for(match)
        event = Icalendar::Event.new
        event.summary = match.name
        event.description = "[#{match.league_name}] - #{match.name}"
        event.dtstart = Icalendar::Values::DateTime.new(match.startTime, "tzid" => "UTC")
        event.dtend = Icalendar::Values::DateTime.new(match.endTime, "tzid" => "UTC")
        event.ip_class = "PUBLIC"
        event
      end
    end
  end
end
