# frozen_string_literal: true

require_relative "fetcher"

module EsportIcs
  module LeagueOfLegends
    module Generator
      class << self
        def generate_calendars
          leagues = Fetcher.fetch_leagues!
          return if leagues.none?

          leagues.each do |league|
            matches = Fetcher.fetch_matches!(league.id)
            next if matches.none?

            calendar = calendar_for(league)

            matches.each do |match|
              event = calendar_event_for(match)
              calendar.add_event(event)
            end

            write_ics(calendar)
          end
        end

        private

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

        def add_match_to(calendar, matches)
          matches.each do |match|
            event = icalendar_event_for(match)
            calendar.add_event(event)
          end
        end

        def write_ics(calendar)
          File.open("ics/league_of_legends/#{calendar.custom_property("slug").first}.ics", "w+") do |f|
            f.write(calendar.to_ical)
          end
        end
      end
    end
  end
end
