# frozen_string_literal: true

require "test_helper"
require_relative "support/game_test_helper"

module EsportIcs
  module Games
    class StarCraftBroodWarTest < Minitest::Test
      include GameTestHelper

      def setup
        @game = StarCraftBroodWar.new
      end
    end
  end
end
