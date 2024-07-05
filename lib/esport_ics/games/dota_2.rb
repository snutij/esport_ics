# frozen_string_literal: true

require_relative "base"

module EsportIcs
  module Games
    class Dota2 < Base
      def initialize
        super(api_code: "dota2", ics_folder: "dota_2")
      end
    end
  end
end
