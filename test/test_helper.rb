# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "esport_ics"

require "minitest/autorun"
require "webmock/minitest"
require "debug"

FIXTURES_PATH = File.expand_path("fixtures", __dir__)
EXPECTATIONS_PATH = File.expand_path("expectations", __dir__)

class FakeHTTPResponse
  attr_reader :code, :body

  def initialize(code, body)
    @code = code
    @body = body
  end
end
