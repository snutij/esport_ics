# frozen_string_literal: true

require "bundler/gem_tasks"

begin
  require "rake/testtask"
  Rake::TestTask.new(:test) do |t|
    t.libs << "test"
    t.libs << "lib"
    t.test_files = FileList["test/**/*_test.rb"]
  end

  require "rubocop/rake_task"
  RuboCop::RakeTask.new

  task default: [:test, :rubocop]
rescue LoadError
  # Dev dependencies not available
end

namespace :esport_ics do
  namespace :generate do
    require "esport_ics"

    desc "Generate Call of Duty Modern Warfare ics files"
    task :call_of_duty_mw do
      EsportIcs::Games::CallOfDutyMW.new.build!.write!
    end

    desc "Generate CSGO ics files"
    task :counter_strike do
      EsportIcs::Games::CounterStrike.new.build!.write!
    end

    desc "Generate Dota 2 ics files"
    task :dota_2 do
      EsportIcs::Games::Dota2.new.build!.write!
    end

    desc "Generate League of Legends ics files"
    task :league_of_legends do
      EsportIcs::Games::LeagueOfLegends.new.build!.write!
    end

    desc "Generate League of Legends Wild Rift ics files"
    task :league_of_legends_wildrift do
      EsportIcs::Games::LeagueOfLegendsWildRift.new.build!.write!
    end

    desc "Generate Overwatch 2 ics files"
    task :overwatch_2 do
      EsportIcs::Games::Overwatch2.new.build!.write!
    end

    desc "Generate R6Siege ics files"
    task :rainbow_six_siege do
      EsportIcs::Games::RainbowSixSiege.new.build!.write!
    end

    desc "Generate Rocket League ics files"
    task :rocket_league do
      EsportIcs::Games::RocketLeague.new.build!.write!
    end

    desc "Generate Valorant ics files"
    task :valorant do
      EsportIcs::Games::Valorant.new.build!.write!
    end

    desc "Run all generators"
    task all: [
      "generate:call_of_duty_mw",
      "generate:counter_strike",
      "generate:dota_2",
      "generate:league_of_legends",
      "generate:league_of_legends_wildrift",
      "generate:overwatch_2",
      "generate:rainbow_six_siege",
      "generate:rocket_league",
      "generate:valorant",
    ]

    desc "Generate static HTML page"
    task :html do
      require_relative "lib/esport_ics/html_generator"
      EsportIcs::HtmlGenerator.new.build!.write!
    end
  end
end
