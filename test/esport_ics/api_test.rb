# frozen_string_literal: true

require "test_helper"

module EsportIcs
  class ApiTest < Minitest::Test
    def setup
      @api = Api.new(game_code: "lol")
    end

    # --- Token validation ---

    def test_raises_when_token_nil
      ENV.stubs(:[]).with("PANDASCORE_API_TOKEN").returns(nil)
      assert_raises(RuntimeError) { @api.fetch_matches! }
    end

    def test_raises_when_token_empty
      ENV.stubs(:[]).with("PANDASCORE_API_TOKEN").returns("")
      assert_raises(RuntimeError) { @api.fetch_matches! }
    end

    # --- URL construction ---

    def test_matches_url
      assert_equal("https://api.pandascore.co/lol/matches/upcoming", @api.matches_url)
    end

    def test_game_code
      assert_equal("lol", @api.game_code)
    end

    def test_different_game_code
      api = Api.new(game_code: "csgo")

      assert_equal("https://api.pandascore.co/csgo/matches/upcoming", api.matches_url)
    end

    # --- Headers ---

    def test_sends_correct_headers
      stub_request(:get, @api.matches_url)
        .with(
          query: { "page[size]" => "100", "page[number]" => "1" },
          headers: {
            "Accept" => "application/json",
            "Authorization" => "Bearer test-token",
          },
        )
        .to_return_json(body: [].to_json)

      @api.fetch_matches!
    end

    # --- Pagination ---

    def test_fetches_multiple_pages
      page1 = [build_api_match(id: 1), build_api_match(id: 2)]
      page2 = [build_api_match(id: 3)]

      stub_request(:get, @api.matches_url)
        .with(query: { "page[size]" => "100", "page[number]" => "1" })
        .to_return_json(body: page1.to_json)

      stub_request(:get, @api.matches_url)
        .with(query: { "page[size]" => "100", "page[number]" => "2" })
        .to_return_json(body: page2.to_json)

      stub_request(:get, @api.matches_url)
        .with(query: { "page[size]" => "100", "page[number]" => "3" })
        .to_return_json(body: [].to_json)

      @api.fetch_matches!

      assert_equal(3, @api.matches.size)
    end

    def test_stops_on_empty_page
      stub_request(:get, @api.matches_url)
        .with(query: { "page[size]" => "100", "page[number]" => "1" })
        .to_return_json(body: [].to_json)

      @api.fetch_matches!

      assert_empty(@api.matches)
    end

    def test_stops_at_max_pagination
      (1..Api::MAX_PAGINATION).each do |page|
        stub_request(:get, @api.matches_url)
          .with(query: { "page[size]" => "100", "page[number]" => page.to_s })
          .to_return_json(body: [build_api_match(id: page)].to_json)
      end

      @api.fetch_matches!

      assert_equal(Api::MAX_PAGINATION, @api.matches.size)
    end

    # --- Filtering ---

    def test_skips_nil_scheduled_at
      matches = [build_api_match(id: 1, scheduled_at: nil)]

      stub_request(:get, @api.matches_url)
        .with(query: { "page[size]" => "100", "page[number]" => "1" })
        .to_return_json(body: matches.to_json)

      stub_request(:get, @api.matches_url)
        .with(query: { "page[size]" => "100", "page[number]" => "2" })
        .to_return_json(body: [].to_json)

      @api.fetch_matches!

      assert_empty(@api.matches)
    end

    def test_skips_empty_opponents
      matches = [build_api_match(id: 1, opponents: [])]

      stub_request(:get, @api.matches_url)
        .with(query: { "page[size]" => "100", "page[number]" => "1" })
        .to_return_json(body: matches.to_json)

      stub_request(:get, @api.matches_url)
        .with(query: { "page[size]" => "100", "page[number]" => "2" })
        .to_return_json(body: [].to_json)

      @api.fetch_matches!

      assert_empty(@api.matches)
    end

    def test_skips_nil_opponents
      matches = [build_api_match(id: 1, opponents: nil)]

      stub_request(:get, @api.matches_url)
        .with(query: { "page[size]" => "100", "page[number]" => "1" })
        .to_return_json(body: matches.to_json)

      stub_request(:get, @api.matches_url)
        .with(query: { "page[size]" => "100", "page[number]" => "2" })
        .to_return_json(body: [].to_json)

      @api.fetch_matches!

      assert_empty(@api.matches)
    end

    # --- Retries ---

    def test_retries_on_server_error
      @api.stubs(:sleep)

      stub_request(:get, @api.matches_url)
        .with(query: { "page[size]" => "100", "page[number]" => "1" })
        .to_return(status: 500, body: "Internal Server Error")
        .then.to_return_json(body: [].to_json)

      @api.fetch_matches!
    end

    def test_raises_after_max_retries
      @api.stubs(:sleep)

      stub_request(:get, @api.matches_url)
        .with(query: { "page[size]" => "100", "page[number]" => "1" })
        .to_return(status: 500, body: "error").times(Api::MAX_RETRIES + 1)

      assert_raises(Api::ServerError) { @api.fetch_matches! }
    end

    def test_retries_on_read_timeout
      @api.stubs(:sleep)

      stub_request(:get, @api.matches_url)
        .with(query: { "page[size]" => "100", "page[number]" => "1" })
        .to_timeout
        .then.to_return_json(body: [].to_json)

      @api.fetch_matches!
    end

    # --- Non-retryable errors ---

    def test_raises_on_401
      stub_request(:get, @api.matches_url)
        .with(query: { "page[size]" => "100", "page[number]" => "1" })
        .to_return(status: 401, body: "Unauthorized")

      assert_raises(RuntimeError) { @api.fetch_matches! }
    end

    def test_raises_on_403
      stub_request(:get, @api.matches_url)
        .with(query: { "page[size]" => "100", "page[number]" => "1" })
        .to_return(status: 403, body: "Forbidden")

      assert_raises(RuntimeError) { @api.fetch_matches! }
    end

    # --- Return value ---

    def test_fetch_matches_returns_self
      stub_request(:get, @api.matches_url)
        .with(query: { "page[size]" => "100", "page[number]" => "1" })
        .to_return_json(body: [].to_json)

      result = @api.fetch_matches!

      assert_same(@api, result)
    end

    private

    def build_api_match(id: 1, scheduled_at: "2024-06-15T18:00:00Z", opponents: :default)
      opponents = [
        { "opponent" => { "name" => "Team A" } },
        { "opponent" => { "name" => "Team B" } },
      ] if opponents == :default

      {
        "id" => id,
        "name" => "Team A vs Team B",
        "scheduled_at" => scheduled_at,
        "number_of_games" => 1,
        "opponents" => opponents,
        "league" => { "name" => "LEC" },
        "serie" => { "full_name" => "Summer 2024" },
        "tournament" => { "name" => "Regular Season" },
        "streams_list" => [],
      }
    end
  end
end
