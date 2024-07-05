# frozen_string_literal: true

require "test_helper"
require_relative "support/game_test_helper"

module EsportIcs
  module Games
    class Dota2Test < Minitest::Test
      include GameTestHelper

      def setup
        @game = Dota2.new
      end
    end
  end
end
