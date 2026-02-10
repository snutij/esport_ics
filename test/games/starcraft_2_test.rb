# frozen_string_literal: true

require "test_helper"
require_relative "support/game_test_helper"

module EsportIcs
  module Games
    class StarCraft2Test < Minitest::Test
      include GameTestHelper

      def setup
        @game = StarCraft2.new
      end
    end
  end
end
