# frozen_string_literal: true

require "test_helper"
require_relative "support/game_test_helper"

module EsportIcs
  module Games
    class KingOfGloryTest < Minitest::Test
      include GameTestHelper

      def setup
        @game = KingOfGlory.new
      end
    end
  end
end
