# frozen_string_literal: true

require_relative "match"

module EsportIcs
  class Api
    BASE_URL = "https://api.pandascore.co"
    MAX_PAGE_SIZE = 100
    MAX_PAGINATION = 20

    attr_reader :matches, :game_code, :matches_url

    def initialize(game_code:)
      @matches = []
      @game_code = game_code
      @matches_url = "#{BASE_URL}/#{game_code}/matches/upcoming"
    end

    def fetch_matches!
      uri = URI(@matches_url)
      page = 1

      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        loop do
          filters = "page[size]=#{MAX_PAGE_SIZE}&page[number]=#{page}"
          api_matches = fetch_data!(http, @matches_url, filters)

          break if api_matches.nil? || api_matches.none?

          api_matches.each do |api_match|
            next if api_match["scheduled_at"].nil?
            next if api_match["opponents"].nil? || api_match["opponents"].empty?

            @matches << Match.new(api_match)
          end

          break if page >= MAX_PAGINATION

          page += 1
        end
      end

      self
    end

    private

    def fetch_data!(http, path, filters = "")
      url = URI(path)
      url.query = filters unless filters.empty?

      request = Net::HTTP::Get.new(url)
      request["accept"] = "application/json"
      request["authorization"] = "Bearer #{ENV["PANDASCORE_API_TOKEN"]}"

      response = http.request(request)

      raise "PandaScore API error: #{response.code} #{response.body}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.read_body)
    end
  end
end
