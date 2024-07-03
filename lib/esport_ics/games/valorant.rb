# frozen_string_literal: true

require_relative "base"

module EsportIcs
  module Games
    class Valorant < Base
      API_SLUG = "valorant"
      PATH_SLUG = "valorant"

      def api_slug
        API_SLUG
      end

      def path_slug
        PATH_SLUG
      end
    end
  end
end
