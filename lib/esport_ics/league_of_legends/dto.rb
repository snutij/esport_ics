# frozen_string_literal: true

module EsportIcs
  module LeagueOfLegends
    module Dto
      Match = Struct.new(:id, :name, :startTime, :endTime, :teams, :league, keyword_init: true)
      Team = Struct.new(:id, :name, :code, keyword_init: true)
      League = Struct.new(:id, :name, :code, keyword_init: true)
    end
  end
end
