# frozen_string_literal: true

require_relative "dto"
require_relative "fetcher"

module EsportIcs
  module LeagueOfLegends
    module Generator
      class << self
        def generate_calendars
          events = Fetcher.new.fetch!
          return if events.none?

          matches = events.map { |event| match_for(event) }

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

        def match_for(event)
          Dto::Match.new(
            id: event.fetch("id"),
            name: event.fetch("name"),
            startTime: Time.strptime(Time.parse(event.fetch("scheduledAt")).to_s, "%Y-%m-%d %H:%M:%S"),
            endTime: Time.strptime((Time.parse(event.fetch("scheduledAt")) + (60 * 60)).to_s, "%Y-%m-%d %H:%M:%S"),
            teams: event.fetch("teams").map do |team|
              Dto::Team.new(
                id: team.fetch("id"),
                name: team.fetch("name"),
                code: team.fetch("code"),
              )
            end,
            league: Dto::League.new(
              id: event.fetch("league").fetch("id"),
              name: event.fetch("league").fetch("name"),
              code: event.fetch("league").fetch("code"),
            ),
          )
        end

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
