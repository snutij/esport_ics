# frozen_string_literal: true

require_relative "base"

module EsportIcs
  module Games
    class RainbowSixSiege < Base
      def initialize
        super(api_code: "r6siege", ics_folder: "rainbow_six_siege")
      end
    end
  end
end
