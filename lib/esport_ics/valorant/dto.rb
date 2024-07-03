# frozen_string_literal: true

module EsportIcs
  module Valorant
    module Dto
      Match = Struct.new(:name, :startTime, :endTime, :teams, keyword_init: true)
      Team = Struct.new(:id, :name, :slug, :acronym, keyword_init: true)
    end
  end
end
