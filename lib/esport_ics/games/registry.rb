# frozen_string_literal: true

require_relative "base"

module EsportIcs
  module Games
    REGISTRY = {
      CallOfDutyMW: { api_code: "codmw", ics_folder: "call_of_duty_mw" },
      CounterStrike: { api_code: "csgo", ics_folder: "counter_strike" },
      Dota2: { api_code: "dota2", ics_folder: "dota_2" },
      LeagueOfLegends: { api_code: "lol", ics_folder: "league_of_legends" },
      LeagueOfLegendsWildRift: { api_code: "lol-wild-rift", ics_folder: "league_of_legends_wildrift" },
      Overwatch2: { api_code: "ow", ics_folder: "overwatch_2" },
      RainbowSixSiege: { api_code: "r6siege", ics_folder: "rainbow_six_siege" },
      RocketLeague: { api_code: "rl", ics_folder: "rocket_league" },
      Valorant: { api_code: "valorant", ics_folder: "valorant" },
    }.freeze

    REGISTRY.each do |class_name, config|
      const_set(class_name, Class.new(Base) do
        define_method(:initialize) { super(**config) }
      end)
    end
  end
end
