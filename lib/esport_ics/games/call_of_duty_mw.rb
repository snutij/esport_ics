# frozen_string_literal: true

require_relative "base"

module EsportIcs
  module Games
    class CallOfDutyMW < Base
      def initialize
        super(api_code: "codmw", ics_folder: "call_of_duty_mw")
      end
    end
  end
end
