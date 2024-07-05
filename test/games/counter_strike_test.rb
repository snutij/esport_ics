# frozen_string_literal: true

require "test_helper"
require_relative "support/game_test_helper"

module EsportIcs
  module Games
    class CounterStrikeTest < Minitest::Test
      include GameTestHelper

      def setup
        @game = CounterStrike.new
      end
    end
  end
end
