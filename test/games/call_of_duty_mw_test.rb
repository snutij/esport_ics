# frozen_string_literal: true

require "test_helper"
require_relative "support/game_test_helper"

module EsportIcs
  module Games
    class CallOfDutyMWTest < Minitest::Test
      include GameTestHelper

      def setup
        @game = CallOfDutyMW.new
      end
    end
  end
end
