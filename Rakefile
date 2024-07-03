# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

require "rubocop/rake_task"

RuboCop::RakeTask.new

namespace :esport_ics do
  namespace :generate do
    require "esport_ics"

    desc "Generate League of Legends ics files"
    task :league_of_legends do
      EsportIcs::Games::LeagueOfLegends.new.generate.write!
    end

    desc "Generate Valorant ics files"
    task :valorant do
      EsportIcs::Games::Valorant.new.generate.write!
    end

    desc "Run all generators"
    task all: ["generate:league_of_legends", "generate:valorant"]
  end
end

task default: [:test, :rubocop]
