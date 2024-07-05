# frozen_string_literal: true

require_relative "base"

module EsportIcs
  module Games
    class CounterStrike < Base
      def initialize
        super(api_code: "csgo", ics_folder: "counter_strike")
      end
    end
  end
end
