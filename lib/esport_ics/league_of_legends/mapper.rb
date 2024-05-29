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
          )
        end
      end
    end
  end
end
