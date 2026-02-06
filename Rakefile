# frozen_string_literal: true

begin
  require "bundler/gem_tasks"
  require "rake/testtask"
  Rake::TestTask.new(:test) do |t|
    t.libs << "test"
    t.libs << "lib"
    t.test_files = FileList["test/**/*_test.rb"]
  end

  require "rubocop/rake_task"
  RuboCop::RakeTask.new

  task(default: [:test, :rubocop])
rescue LoadError
  # Dev dependencies not available (e.g., production builds)
end

namespace :esport_ics do
  namespace :generate do
    namespace :ics do
      desc "Load esport_ics gem"
      task :setup do
        require "esport_ics"
      end

      desc "Generate Call of Duty Modern Warfare ics files"
      task call_of_duty_mw: :setup do
        EsportIcs::Games::CallOfDutyMW.new.build!.write!
      end

      desc "Generate CSGO ics files"
      task counter_strike: :setup do
        EsportIcs::Games::CounterStrike.new.build!.write!
      end

      desc "Generate Dota 2 ics files"
      task dota_2: :setup do
        EsportIcs::Games::Dota2.new.build!.write!
      end

      desc "Generate League of Legends ics files"
      task league_of_legends: :setup do
        EsportIcs::Games::LeagueOfLegends.new.build!.write!
      end

      desc "Generate League of Legends Wild Rift ics files"
      task league_of_legends_wildrift: :setup do
        EsportIcs::Games::LeagueOfLegendsWildRift.new.build!.write!
      end

      desc "Generate Overwatch 2 ics files"
      task overwatch_2: :setup do
        EsportIcs::Games::Overwatch2.new.build!.write!
      end

      desc "Generate R6Siege ics files"
      task rainbow_six_siege: :setup do
        EsportIcs::Games::RainbowSixSiege.new.build!.write!
      end

      desc "Generate Rocket League ics files"
      task rocket_league: :setup do
        EsportIcs::Games::RocketLeague.new.build!.write!
      end

      desc "Generate Valorant ics files"
      task valorant: :setup do
        EsportIcs::Games::Valorant.new.build!.write!
      end

      desc "Run all ICS generators"
      task(all: [
        :call_of_duty_mw,
        :counter_strike,
        :dota_2,
        :league_of_legends,
        :league_of_legends_wildrift,
        :overwatch_2,
        :rainbow_six_siege,
        :rocket_league,
        :valorant,
      ])
    end

    desc "Generate static HTML page"
    task :html do
      require_relative "lib/esport_ics/html_generator"
      EsportIcs::HtmlGenerator.new.build!.write!
    end
  end
end
