# frozen_string_literal: true

require_relative "dto"
require_relative "fetcher"
require_relative "mapper"

module EsportIcs
  module LeagueOfLegends
    module Generator
      class << self
        def generate_calendars
          events = Fetcher.new.fetch!
          return if events.none?

          matches = Mapper.new(events).to_matches!

          calendars = matches.map(&:league).uniq.map { |league| icalendar_for(league) }.push(
            icalendar_for(Dto::League.new(id: "all", name: "All Leagues", code: "all")),
          )

          matches.each do |match|
            event = icalendar_event_for(match)
            calendars.find { |c| c.custom_property("id").first == "all" }.add_event(event)
            calendars.find { |c| c.custom_property("id").first == match.league.id.to_s }.add_event(event)
          end

          calendars
        end

        def write_ics(calendars)
          calendars.each do |cal|
            File.open("ics/league_of_legends/#{cal.custom_property("code").first}.ics", "w+") do |f|
              f.write(cal.to_ical)
            end
          end
        end

        private

        def icalendar_for(league)
          cal = Icalendar::Calendar.new
          cal.append_custom_property("name", league.name)
          cal.append_custom_property("description", "#{league.name} games schedule")
          cal.append_custom_property("code", league.code)
          cal.append_custom_property("id", league.id.to_s)
          cal.publish
          cal
        end

        def icalendar_event_for(match)
          event = Icalendar::Event.new
          event.dtstart = Icalendar::Values::DateTime.new(match.startTime, "tzid" => "UTC")
          event.dtend = Icalendar::Values::DateTime.new(match.endTime, "tzid" => "UTC")
          event.summary = match.name
          event.description = "[#{match.league.name}] - #{match.teams.map(&:name).join(" vs ")}"
          event.ip_class = "PUBLIC"
          event
        end
      end
    end
  end
end
