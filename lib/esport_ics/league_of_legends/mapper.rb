# frozen_string_literal: true

require_relative "dto"

module EsportIcs
  module LeagueOfLegends
    module Mapper
      ONE_HOUR_IN_SECONDS = 3600
      SLUG_PREFIX = "league-of-legends-"

      class << self
        def to_leagues!(api_league)
          Dto::League.new(
            id: api_league.fetch("id"),
            name: api_league.fetch("name"),
            slug: api_league.fetch("slug").delete_prefix(SLUG_PREFIX),
          )
        end

        def to_matches!(api_match)
          Dto::Match.new(
            name: api_match.fetch("name"),
            startTime: Time.parse(api_match.fetch("scheduled_at")),
            endTime:  Time.parse(api_match.fetch("scheduled_at")) + ONE_HOUR_IN_SECONDS,
            league_name: api_match.dig("league", "name"),
            teams: api_match.fetch("opponents").map { |opponent| to_teams!(opponent.fetch("opponent")) },
          )
        end

        def to_teams!(api_team)
          Dto::Team.new(
            name: api_team.fetch("name"),
            slug: api_team.fetch("slug"),
          )
        end

        def to_ical(group)
          calendar = Icalendar::Calendar.new
          calendar.append_custom_property("name", group.name)
          calendar.append_custom_property("slug", group.slug)
          calendar.publish
          calendar
        end

        def to_event(match)
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
end
