# frozen_string_literal: true

require_relative "match"

module EsportIcs
  class Api
    BASE_URL = "https://api.pandascore.co"
    MAX_PAGE_SIZE = 100
    MAX_PAGINATION = 20
    MAX_RETRIES = 3
    OPEN_TIMEOUT = 10
    READ_TIMEOUT = 30

    class ServerError < StandardError
    end

    attr_reader :matches, :game_code, :matches_url

    def initialize(game_code:)
      @matches = []
      @game_code = game_code
      @matches_url = "#{BASE_URL}/#{game_code}/matches/upcoming"
    end

    def fetch_matches!
      raise "PANDASCORE_API_TOKEN is not set" if ENV["PANDASCORE_API_TOKEN"].nil? || ENV["PANDASCORE_API_TOKEN"].empty?

      uri = URI(@matches_url)
      page = 1

      Net::HTTP.start(
        uri.host,
        uri.port,
        use_ssl: true,
        open_timeout: OPEN_TIMEOUT,
        read_timeout: READ_TIMEOUT,
      ) do |http|
        loop do
          filters = "page[size]=#{MAX_PAGE_SIZE}&page[number]=#{page}"
          api_matches = fetch_data!(http, @matches_url, filters)

          break if api_matches.nil? || api_matches.none?

          api_matches.each do |api_match|
            next if api_match["scheduled_at"].nil?
            next if api_match["opponents"].nil? || api_match["opponents"].empty?

            @matches << Match.new(api_match)
          end

          if page >= MAX_PAGINATION
            $stderr.puts "Warning: pagination limit (#{MAX_PAGINATION}) reached for #{game_code}, results may be incomplete"
            break
          end

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

      retries = 0
      begin
        response = http.request(request)

        raise ServerError, "#{response.code} #{response.body}" if response.is_a?(Net::HTTPServerError)
        raise "PandaScore API error: #{response.code} #{response.body}" unless response.is_a?(Net::HTTPSuccess)

        JSON.parse(response.read_body)
      rescue ServerError, Net::OpenTimeout, Net::ReadTimeout => e
        retries += 1
        raise if retries > MAX_RETRIES

        $stderr.puts "PandaScore API retry #{retries}/#{MAX_RETRIES} for #{game_code}: #{e.message}"
        sleep(2**retries)
        retry
      end
    end
  end
end
