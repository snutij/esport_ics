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
  namespace :league_of_legends do
    desc "Generate League of Legends ics files"
    task :generate do
      require "esport_ics"

      EsportIcs::LeagueOfLegends::Generator.create!
    end
  end
end

task default: [:test, :rubocop]
