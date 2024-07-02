# frozen_string_literal: true

require_relative "dto"

module EsportIcs
  module LeagueOfLegends
    module Mapper
      ONE_HOUR_IN_SECONDS = 3600

      class << self
        def to_match(api_match)
          Dto::Match.new(
            name: api_match.fetch("name"),
            startTime: Time.parse(api_match.fetch("scheduled_at")),
            endTime:  Time.parse(api_match.fetch("scheduled_at")) + ONE_HOUR_IN_SECONDS,
            teams: api_match.fetch("opponents").map { |opponent| to_teams(opponent.fetch("opponent")) },
          )
        end

        def to_teams(api_team)
          Dto::Team.new(
            id: api_team.fetch("id"),
            name: api_team.fetch("name"),
            slug: api_team.fetch("name").parameterize,
            acronym: api_team.fetch("acronym"),
          )
        end

        def to_ical(team)
          calendar = Icalendar::Calendar.new
          calendar.append_custom_property("slug", team.slug)
          calendar.publish
          calendar
        end

        def to_event(match)
          event = Icalendar::Event.new
          event.summary = match.name
          event.dtstart = Icalendar::Values::DateTime.new(match.startTime, "tzid" => "UTC")
          event.dtend = Icalendar::Values::DateTime.new(match.endTime, "tzid" => "UTC")
          event.ip_class = "PUBLIC"
          event
        end
      end
    end
  end
end
