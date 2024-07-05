# frozen_string_literal: true

require_relative "team"

module EsportIcs
  class Match
    ONE_HOUR_IN_SECONDS = 3600

    attr_reader :teams

    def initialize(api_match)
      @name = api_match.fetch("name")
      @start_time = Time.parse(api_match.fetch("scheduled_at"))
      @end_time = Time.parse(api_match.fetch("scheduled_at")) + ONE_HOUR_IN_SECONDS
      @teams = api_match.fetch("opponents").map { |opponent| Team.new(opponent.fetch("opponent")) }
    end

    def to_event
      event = Icalendar::Event.new
      event.summary = @name
      event.dtstart = Icalendar::Values::DateTime.new(@start_time, "tzid" => "UTC")
      event.dtend = Icalendar::Values::DateTime.new(@end_time, "tzid" => "UTC")
      event.ip_class = "PUBLIC"
      event
    end
  end
end
