# frozen_string_literal: true

require_relative "mapper"

module EsportIcs
  module LeagueOfLegends
    module Fetcher
      BASE_URL = "https://api.pandascore.co/lol"
      LEAGUE_PATH = "#{BASE_URL}/leagues"
      MATCHES_PATH = "#{BASE_URL}/matches/upcoming"
      LEAGUE_MAX_PAGE_SIZE = 100

      class << self
        def fetch_leagues!
          filters = "page[size]=#{LEAGUE_MAX_PAGE_SIZE}"

          fetch_data!(LEAGUE_PATH, filters).map do |api_league|
            Mapper.to_leagues(api_league)
          end
        end

        def fetch_matches!(league_id = nil)
          filters = "filter[league_id]=#{league_id}" if league_id

          fetch_data!(MATCHES_PATH, filters).map do |api_match|
            Mapper.to_matches(api_match)
          end
        end

        private

        def fetch_data!(path, filters = "")
          url = URI(path)
          url.query = filters unless filters.empty?

          http = Net::HTTP.new(url.host, url.port)
          http.use_ssl = true

          request = Net::HTTP::Get.new(url)
          request["accept"] = "application/json"
          request["authorization"] = "Bearer #{ENV["PANDASCORE_API_TOKEN"]}"

          response = http.request(request)

          JSON.parse(response.read_body)
        end
      end
    end
  end
end
