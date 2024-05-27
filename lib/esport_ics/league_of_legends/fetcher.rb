# frozen_string_literal: true

require_relative "league"

module EsportIcs
  module LeagueOfLegends
    class Fetcher
      BASE_URL = "https://api.teamswap.io/api/v2/lol/leagues/schedule"
      MAX_EVENTS = 100
      MAX_PAGINATION = 30

      def initialize
        @uri = URI(BASE_URL)
        @events = []
        @page = 0
      end

      def fetch!
        loop do
          params = { page: @page, league: League::ALL }
          @uri.query = URI.encode_www_form(params)

          response = Net::HTTP.get_response(@uri)

          break unless response.code == "200"

          body = JSON.parse(response.body)
          @events.concat(body.fetch("data", []))

          break if body.empty? || @events.length >= MAX_EVENTS || @page >= MAX_PAGINATION

          @page += 1
        end

        @events
      end
    end
  end
end
