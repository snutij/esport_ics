# frozen_string_literal: true

require "simplecov"
SimpleCov.start

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "esport_ics"

require "debug"
require "minitest/autorun"
require "mocha/minitest"
require "webmock/minitest"

ENV["PANDASCORE_API_TOKEN"] ||= "test-token"
