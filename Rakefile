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

      require_relative "lib/esport_ics/games/registry"

      EsportIcs::Games::REGISTRY.each do |class_name, config|
        task_name = config[:ics_folder]

        desc "Generate #{class_name} ics files"
        task task_name => :setup do
          EsportIcs::Games.const_get(class_name).new.build!.write!
        end
      end

      desc "Run all ICS generators in parallel"
      task all: :setup do
        threads = EsportIcs::Games::REGISTRY.map do |class_name, _|
          Thread.new do
            EsportIcs::Games.const_get(class_name).new.build!.write!
          end
        end
        threads.each(&:join)
      end
    end

    desc "Generate static HTML page"
    task :html do
      require_relative "lib/esport_ics/html_generator"
      EsportIcs::HtmlGenerator.new.build!.write!
    end
  end
end
