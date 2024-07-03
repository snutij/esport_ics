# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "esport_ics"

require "debug"
require "minitest/autorun"
require "mocha/minitest"
require "webmock/minitest"

FIXTURES_PATH = File.expand_path("fixtures", __dir__)
EXPECTATIONS_PATH = File.expand_path("expectations", __dir__)

def assert_same_calendar(calendar, expected_ics)
  assert(calendar)
  assert(expected_ics)

  assert_equal(calendar.custom_property("name"), expected_ics.custom_property("name"))
  assert_equal(calendar.custom_property("slug"), expected_ics.custom_property("slug"))
  assert_equal(calendar.ip_name, expected_ics.ip_name)
  assert_equal(calendar.ip_method, expected_ics.ip_method)
  assert_equal(calendar.events.size, expected_ics.events.size)

  calendar.events.zip(expected_ics.events).each do |event, expected_event|
    assert_equal(event.summary, expected_event.summary)
    assert_equal(event.ip_class, expected_event.ip_class)
    assert_equal(event.dtstart.to_s, expected_event.dtstart.to_s)
    assert_equal(event.dtend.to_s, expected_event.dtend.to_s)
  end
end

def stub_matches_league(game_slug)
  mock_matches = File.read(File.join(FIXTURES_PATH, game_slug, "matches.json"))

  stub_request(
    :get,
    "#{EsportIcs::Api.new(game_slug: game_slug).matches_url}?page[size]=100&page[number]=1",
  ).to_return_json(body: JSON.parse(mock_matches).to_json)

  stub_request(
    :get,
    "#{EsportIcs::Api.new(game_slug: game_slug).matches_url}?page[size]=100&page[number]=2",
  ).to_return_json(body: [].to_json)

  yield
end
