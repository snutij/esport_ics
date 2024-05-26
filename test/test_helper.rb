# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "esport_ics"

require "minitest/autorun"
require "debug"
require "time"

class FakeHTTPResponse
  attr_reader :code, :body

  def initialize(code, body)
    @code = code
    @body = body
  end
end
