# frozen_string_literal: true

require_relative "base"

module EsportIcs
  module Games
    class RocketLeague < Base
      def initialize
        super(api_code: "rl", ics_folder: "rocket_league")
      end
    end
  end
end
