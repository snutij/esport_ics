# frozen_string_literal: true

module EsportIcs
  module LeagueOfLegends
    module Dto
      League = Struct.new(:id, :name, :slug, keyword_init: true)
      Match = Struct.new(:name, :startTime, :endTime, :league_name, keyword_init: true)
    end
  end
end
