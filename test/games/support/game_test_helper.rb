# frozen_string_literal: true

require "tmpdir"

module EsportIcs
  module Games
    module GameTestHelper
      FIXTURES_DIR = "test/fixtures"
      EXPECTATIONS_DIR = "test/expectations"

      class << self
        def included(base)
          base.class_eval do
            def test_create_ics
              expected_ics = Dir.glob(File.join(EXPECTATIONS_DIR, @game.folder, "*.ics")).map do |f|
                File.read(f)
              end

              with_matches_stubbed do
                calendars = @game.build!.calendars.values.map(&:to_ical)

                assert_equal(calendars.size, expected_ics.size)

                calendars.concat(expected_ics).map { |c| Icalendar::Calendar.parse(c).first }
                  .group_by { |c| c.custom_property("slug").first }
                  .each { |_slug, (cal, exp)| assert_same_calendar(cal, exp) }
              end
            end

            def test_write_ics_files
              Dir.mktmpdir do |tmpdir|
                with_matches_stubbed do
                  @game.build!

                  old_ics_path = Games::Base::ICS_PATH
                  Games::Base.send(:remove_const, :ICS_PATH)
                  Games::Base.const_set(:ICS_PATH, "#{tmpdir}/:folder/:team.ics")

                  result = @game.write!

                  assert_same(@game, result)
                  @game.calendars.each_key do |team_slug|
                    assert_path_exists(File.join(tmpdir, @game.folder, "#{team_slug}.ics"))
                  end
                ensure
                  Games::Base.send(:remove_const, :ICS_PATH)
                  Games::Base.const_set(:ICS_PATH, old_ics_path)
                end
              end
            end

            def with_matches_stubbed
              mock_matches = File.read(File.join(FIXTURES_DIR, @game.folder, "matches.json"))

              stub_request(:get, Api.new(game_code: @game.api_code).matches_url)
                .with(query: { "page[size]": 100, "page[number]": 1 })
                .to_return_json(body: JSON.parse(mock_matches).to_json)

              stub_request(:get, Api.new(game_code: @game.api_code).matches_url)
                .with(query: { "page[size]": 100, "page[number]": 2 })
                .to_return_json(body: [].to_json)

              yield
            end
          end
        end
      end

      def assert_same_calendar(calendar, expected_ics)
        assert(calendar)
        assert(expected_ics)

        assert_equal(calendar.custom_property("x-wr-calname"), expected_ics.custom_property("x-wr-calname"))
        assert_equal(calendar.custom_property("slug"), expected_ics.custom_property("slug"))
        assert_equal(calendar.ip_name, expected_ics.ip_name)
        assert_equal(calendar.ip_method, expected_ics.ip_method)
        assert_equal(calendar.events.size, expected_ics.events.size)

        calendar.events.zip(expected_ics.events).each do |event, expected_event|
          assert_equal(event.uid, expected_event.uid)
          assert_equal(event.summary, expected_event.summary)
          assert_equal(event.description, expected_event.description)
          assert_equal(event.ip_class, expected_event.ip_class)
          assert_equal(event.dtstart.to_s, expected_event.dtstart.to_s)
          assert_equal(event.dtend.to_s, expected_event.dtend.to_s)
        end
      end
    end

    # Auto-generate test classes for every game that has fixtures
    REGISTRY.each do |class_name, config|
      next unless File.exist?(File.join(GameTestHelper::FIXTURES_DIR, config[:ics_folder], "matches.json"))

      test_class = Class.new(Minitest::Test) do
        include GameTestHelper

        define_method(:setup) { @game = Games.const_get(class_name).new }
      end

      const_set(:"#{class_name}Test", test_class)
    end
  end
end
