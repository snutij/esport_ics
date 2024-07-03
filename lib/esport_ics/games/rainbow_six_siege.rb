# frozen_string_literal: true

require_relative "base"

module EsportIcs
  module Games
    class RainbowSixSiege < Base
      API_SLUG = "r6siege"
      PATH_SLUG = "rainbow_six_siege"

      def api_slug
        API_SLUG
      end

      def path_slug
        PATH_SLUG
      end
    end
  end
end
