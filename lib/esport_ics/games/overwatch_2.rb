# frozen_string_literal: true

require_relative "base"

module EsportIcs
  module Games
    class Overwatch2 < Base
      def initialize
        super(api_code: "ow", ics_folder: "overwatch_2")
      end
    end
  end
end
