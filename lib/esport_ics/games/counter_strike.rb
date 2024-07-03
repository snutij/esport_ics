# frozen_string_literal: true

require_relative "base"

module EsportIcs
  module Games
    class CounterStrike < Base
      API_SLUG = "csgo"
      PATH_SLUG = "counter_strike"

      def api_slug
        API_SLUG
      end

      def path_slug
        PATH_SLUG
      end
    end
  end
end
