# frozen_string_literal: true

require_relative "base"

module EsportIcs
  module Games
    class Dota2 < Base
      API_SLUG = "dota2"
      PATH_SLUG = "dota_2"

      def api_slug
        API_SLUG
      end

      def path_slug
        PATH_SLUG
      end
    end
  end
end
