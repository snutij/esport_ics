# frozen_string_literal: true

require "json"
require "net/http"
require "icalendar"

module EsportIcs
  class Error < StandardError; end
  require_relative "esport_ics/league_of_legends/generator"
end
