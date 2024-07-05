# frozen_string_literal: true

require_relative "base"

module EsportIcs
  module Games
    class LeagueOfLegendsWildRift < Base
      def initialize
        super(api_code: "lol-wild-rift", ics_folder: "league_of_legends_wildrift")
      end
    end
  end
end
