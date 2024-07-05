# frozen_string_literal: true

require_relative "base"

module EsportIcs
  module Games
    class Valorant < Base
      def initialize
        super(api_code: "valorant", ics_folder: "valorant")
      end
    end
  end
end
