# frozen_string_literal: true

require_relative "team"

module EsportIcs
  class Match
    SECONDS_PER_GAME = 2700 # 45 minutes

    attr_reader :teams

    def initialize(api_match)
      @id = api_match.fetch("id")
      @name = api_match.fetch("name")
      @start_time = Time.parse(api_match.fetch("scheduled_at"))

      number_of_games = api_match.fetch("number_of_games", 1)
      number_of_games = 1 if number_of_games.nil? || number_of_games < 1
      @end_time = @start_time + (number_of_games * SECONDS_PER_GAME)

      @teams = api_match.fetch("opponents").map { |opponent| Team.new(opponent.fetch("opponent")) }

      league_name = api_match.dig("league", "name")
      serie_name = api_match.dig("serie", "full_name")
      tournament_name = api_match.dig("tournament", "name")
      @context = [league_name, serie_name, tournament_name].compact.reject(&:empty?).join(" - ")

      stream = Array(api_match["streams_list"]).find { |s| s["main"] && s["official"] }
      @stream_url = stream&.dig("raw_url")
    end

    def to_event
      event = Icalendar::Event.new
      event.uid = "pandascore-match-#{@id}@esport-ics"
      event.summary = @name
      event.dtstart = Icalendar::Values::DateTime.new(@start_time, "tzid" => "UTC")
      event.dtend = Icalendar::Values::DateTime.new(@end_time, "tzid" => "UTC")
      event.dtstamp = Icalendar::Values::DateTime.new(@start_time, "tzid" => "UTC")
      event.ip_class = "PUBLIC"

      description_parts = []
      description_parts << @context unless @context.empty?
      description_parts << "Watch: #{@stream_url}" if @stream_url
      event.description = description_parts.join("\n") unless description_parts.empty?

      event.url = @stream_url if @stream_url

      event
    end
  end
end
