# frozen_string_literal: true

require_relative "base"

module EsportIcs
  module Games
    class LeagueOfLegendsWildRift < Base
      API_SLUG = "lol-wild-rift"
      PATH_SLUG = "league_of_legends_wildrift"

      def api_slug
        API_SLUG
      end

      def path_slug
        PATH_SLUG
      end
    end
  end
end
