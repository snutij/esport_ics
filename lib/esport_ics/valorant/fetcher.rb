# frozen_string_literal: true

require_relative "mapper"

module EsportIcs
  module Valorant
    module Fetcher
      BASE_URL = "https://api.pandascore.co/valorant"
      MATCHES_PATH = "#{BASE_URL}/matches/upcoming"
      MAX_PAGE_SIZE = 100
      MAX_PAGINATION = 20

      class << self
        def fetch_matches!
          matches = []
          page = 1

          loop do
            filters = "page[size]=#{MAX_PAGE_SIZE}&page[number]=#{page}"
            api_matches = fetch_data!(MATCHES_PATH, filters)

            # Break the loop if no matches are returned
            break if api_matches.nil? || api_matches.none?

            # Process each match and add it to the matches array
            api_matches.each do |api_match|
              matches << Mapper.to_match(api_match)
            end

            # Break the loop if the maximum pagination is reached
            break if page >= MAX_PAGINATION

            # Increment the page number for the next iteration
            page += 1
          end

          matches
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
