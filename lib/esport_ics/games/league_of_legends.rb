# frozen_string_literal: true

require_relative "base"

module EsportIcs
  module Games
    class LeagueOfLegends < Base
      API_SLUG = "lol"
      PATH_SLUG = "league_of_legends"

      def api_slug
        API_SLUG
      end

      def path_slug
        PATH_SLUG
      end
    end
  end
end
