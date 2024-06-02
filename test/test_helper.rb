# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "esport_ics"

require "debug"
require "minitest/autorun"
require "mocha/minitest"
require "webmock/minitest"

FIXTURES_PATH = File.expand_path("fixtures", __dir__)
EXPECTATIONS_PATH = File.expand_path("expectations", __dir__)
