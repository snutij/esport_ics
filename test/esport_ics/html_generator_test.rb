# frozen_string_literal: true

require "test_helper"
require "esport_ics/html_generator"
require "tmpdir"

module EsportIcs
  class HtmlGeneratorTest < Minitest::Test
    def setup
      @generator = HtmlGenerator.new
    end

    # --- GAME_CONFIG / GAME_ORDER consistency ---

    def test_game_config_keys_match_game_order
      assert_equal(HtmlGenerator::GAME_ORDER.sort, HtmlGenerator::GAME_CONFIG.keys.sort)
    end

    def test_game_order_has_no_duplicates
      assert_equal(HtmlGenerator::GAME_ORDER.size, HtmlGenerator::GAME_ORDER.uniq.size)
    end

    # --- scan_ics_directory ---

    def test_scan_ics_directory_finds_games
      Dir.mktmpdir do |tmpdir|
        create_mock_ics_structure(tmpdir)

        generator = HtmlGenerator.new
        stub_const(generator, :ICS_DIR, tmpdir) do
          generator.build!
          games = generator.instance_variable_get(:@games)

          assert_includes(games.keys, "game_a")
          assert_includes(games.keys, "game_b")
        end
      end
    end

    def test_scan_ics_directory_extracts_team_names
      Dir.mktmpdir do |tmpdir|
        create_mock_ics_structure(tmpdir)

        generator = HtmlGenerator.new
        stub_const(generator, :ICS_DIR, tmpdir) do
          generator.build!
          games = generator.instance_variable_get(:@games)

          team_names = games["game_a"].map { |t| t[:name] }

          assert_includes(team_names, "Team Alpha")
          assert_includes(team_names, "Team Beta")
        end
      end
    end

    def test_scan_ics_directory_sorts_alphabetically
      Dir.mktmpdir do |tmpdir|
        create_mock_ics_structure(tmpdir)

        generator = HtmlGenerator.new
        stub_const(generator, :ICS_DIR, tmpdir) do
          generator.build!
          games = generator.instance_variable_get(:@games)

          names = games["game_a"].map { |t| t[:name] }

          assert_equal(names, names.sort_by(&:downcase))
        end
      end
    end

    def test_scan_ics_directory_skips_non_directories
      Dir.mktmpdir do |tmpdir|
        FileUtils.mkdir_p("#{tmpdir}/game_a")
        File.write("#{tmpdir}/game_a/team-alpha.ics", "")
        File.write("#{tmpdir}/not-a-dir.txt", "")

        generator = HtmlGenerator.new
        stub_const(generator, :ICS_DIR, tmpdir) do
          generator.build!
          games = generator.instance_variable_get(:@games)

          refute_includes(games.keys, "not-a-dir.txt")
        end
      end
    end

    # --- generate_html sections ---

    def test_generate_html_includes_header
      Dir.mktmpdir do |tmpdir|
        create_mock_ics_structure(tmpdir)

        generator = HtmlGenerator.new
        stub_const(generator, :ICS_DIR, tmpdir) do
          generator.build!
          html = generator.send(:generate_html)

          assert_includes(html, "Esport ICS Calendars")
          assert_includes(html, "<header")
        end
      end
    end

    def test_generate_html_includes_tutorial
      Dir.mktmpdir do |tmpdir|
        create_mock_ics_structure(tmpdir)

        generator = HtmlGenerator.new
        stub_const(generator, :ICS_DIR, tmpdir) do
          generator.build!
          html = generator.send(:generate_html)

          assert_includes(html, "How to Subscribe")
          assert_includes(html, "tutorial")
        end
      end
    end

    def test_generate_html_includes_search
      Dir.mktmpdir do |tmpdir|
        create_mock_ics_structure(tmpdir)

        generator = HtmlGenerator.new
        stub_const(generator, :ICS_DIR, tmpdir) do
          generator.build!
          html = generator.send(:generate_html)

          assert_includes(html, "search-input")
          assert_includes(html, "Search teams")
        end
      end
    end

    def test_generate_html_includes_footer
      Dir.mktmpdir do |tmpdir|
        create_mock_ics_structure(tmpdir)

        generator = HtmlGenerator.new
        stub_const(generator, :ICS_DIR, tmpdir) do
          generator.build!
          html = generator.send(:generate_html)

          assert_includes(html, "<footer")
          assert_includes(html, "auto-update every 12 hours")
        end
      end
    end

    def test_generate_html_includes_scripts
      Dir.mktmpdir do |tmpdir|
        create_mock_ics_structure(tmpdir)

        generator = HtmlGenerator.new
        stub_const(generator, :ICS_DIR, tmpdir) do
          generator.build!
          html = generator.send(:generate_html)

          assert_includes(html, "<script>")
          assert_includes(html, "filterTeams")
        end
      end
    end

    def test_generate_html_includes_svg_symbols
      Dir.mktmpdir do |tmpdir|
        create_mock_ics_structure(tmpdir)

        generator = HtmlGenerator.new
        stub_const(generator, :ICS_DIR, tmpdir) do
          generator.build!
          html = generator.send(:generate_html)

          assert_includes(html, "icon-copy")
          assert_includes(html, "icon-github")
        end
      end
    end

    # --- Game ordering ---

    def test_games_ordered_by_game_order
      Dir.mktmpdir do |tmpdir|
        # Create dirs matching GAME_ORDER entries
        ["valorant", "league_of_legends", "counter_strike"].each do |game|
          FileUtils.mkdir_p("#{tmpdir}/#{game}")
          File.write("#{tmpdir}/#{game}/team-a.ics", "")
        end

        generator = HtmlGenerator.new
        stub_const(generator, :ICS_DIR, tmpdir) do
          generator.build!
          html = generator.send(:generate_html)

          lol_pos = html.index('data-game="league_of_legends"')
          cs_pos = html.index('data-game="counter_strike"')
          val_pos = html.index('data-game="valorant"')

          assert_operator(lol_pos, :<, cs_pos, "LoL should appear before CS")
          assert_operator(cs_pos, :<, val_pos, "CS should appear before Valorant")
        end
      end
    end

    # --- Accent colors ---

    def test_accent_colors_applied_per_game
      Dir.mktmpdir do |tmpdir|
        FileUtils.mkdir_p("#{tmpdir}/valorant")
        File.write("#{tmpdir}/valorant/team-a.ics", "")

        generator = HtmlGenerator.new
        stub_const(generator, :ICS_DIR, tmpdir) do
          generator.build!
          html = generator.send(:generate_html)

          assert_includes(html, HtmlGenerator::GAME_CONFIG["valorant"][:accent])
        end
      end
    end

    # --- write! ---

    def test_write_creates_output_file
      Dir.mktmpdir do |tmpdir|
        create_mock_ics_structure(tmpdir)
        output_file = File.join(tmpdir, "output.html")

        generator = HtmlGenerator.new
        stub_const(generator, :ICS_DIR, tmpdir) do
          stub_const(generator, :OUTPUT_FILE, output_file) do
            generator.build!
            result = generator.write!

            assert_path_exists(output_file)
            assert_includes(File.read(output_file), "<!DOCTYPE html>")
            assert_same(generator, result)
          end
        end
      end
    end

    # --- GitHub raw URLs ---

    def test_github_raw_urls_constructed_correctly
      Dir.mktmpdir do |tmpdir|
        FileUtils.mkdir_p("#{tmpdir}/valorant")
        File.write("#{tmpdir}/valorant/team-a.ics", "")

        generator = HtmlGenerator.new
        stub_const(generator, :ICS_DIR, tmpdir) do
          generator.build!
          html = generator.send(:generate_html)

          expected_url = "#{HtmlGenerator::GITHUB_RAW_URL}/valorant/team-a.ics"

          assert_includes(html, expected_url)
        end
      end
    end

    private

    def create_mock_ics_structure(tmpdir)
      ["game_a", "game_b"].each do |game|
        FileUtils.mkdir_p("#{tmpdir}/#{game}")
        File.write("#{tmpdir}/#{game}/team-alpha.ics", "")
        File.write("#{tmpdir}/#{game}/team-beta.ics", "")
      end
    end

    def stub_const(obj, const_name, value)
      old_value = obj.class.const_get(const_name)
      obj.class.send(:remove_const, const_name)
      obj.class.const_set(const_name, value)
      yield
    ensure
      obj.class.send(:remove_const, const_name)
      obj.class.const_set(const_name, old_value)
    end
  end
end
