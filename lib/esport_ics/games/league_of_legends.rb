# frozen_string_literal: true

require_relative "base"

module EsportIcs
  module Games
    class LeagueOfLegends < Base
      def initialize
        super(api_code: "lol", ics_folder: "league_of_legends")
      end
    end
  end
end
