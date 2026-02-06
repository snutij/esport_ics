# frozen_string_literal: true

module EsportIcs
  class HtmlGenerator
    ICS_DIR = "ics"
    OUTPUT_FILE = "index.html"
    GITHUB_RAW_URL = "https://raw.githubusercontent.com/snutij/esport_ics/main/ics"

    # Ordered by popularity (viewership/player base)
    GAME_ORDER = [
      "league_of_legends",
      "counter_strike",
      "valorant",
      "dota_2",
      "call_of_duty_mw",
      "overwatch_2",
      "rocket_league",
      "rainbow_six_siege",
      "league_of_legends_wildrift",
    ].freeze

    GAME_CONFIG = {
      "call_of_duty_mw" => { name: "Call of Duty", accent: "#f6a800", icon: "🎯" },
      "counter_strike" => { name: "Counter-Strike 2", accent: "#de9b35", icon: "💣" },
      "dota_2" => { name: "Dota 2", accent: "#c23c2a", icon: "⚔️" },
      "league_of_legends" => { name: "League of Legends", accent: "#c9aa71", icon: "🏆" },
      "league_of_legends_wildrift" => { name: "LoL Wild Rift", accent: "#1ca5b8", icon: "📱" },
      "overwatch_2" => { name: "Overwatch 2", accent: "#fa9c1e", icon: "🛡️" },
      "rainbow_six_siege" => { name: "Rainbow Six Siege", accent: "#7c7c7c", icon: "🔫" },
      "rocket_league" => { name: "Rocket League", accent: "#0072ce", icon: "🚗" },
      "valorant" => { name: "Valorant", accent: "#ff4655", icon: "🔺" },
    }.freeze

    def initialize
      @games = {}
    end

    def build!
      scan_ics_directory
      self
    end

    def write!
      File.write(OUTPUT_FILE, generate_html)
      self
    end

    private

    def scan_ics_directory
      Dir.glob("#{ICS_DIR}/*").each do |game_dir|
        next unless File.directory?(game_dir)

        game_slug = File.basename(game_dir)
        teams = Dir.glob("#{game_dir}/*.ics").map do |ics_file|
          team_slug = File.basename(ics_file, ".ics")
          team_name = team_slug.split("-").map(&:capitalize).join(" ")
          { slug: team_slug, name: team_name }
        end.sort_by { |t| t[:name].downcase }

        @games[game_slug] = teams if teams.any?
      end
    end

    def generate_html
      <<~HTML
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Esport ICS Calendars</title>
          #{generate_styles}
        </head>
        <body>
          <div class="container">
            #{generate_header}
            #{generate_tutorial}
            #{generate_search}
            #{generate_games}
            #{generate_footer}
          </div>
          #{generate_scripts}
        </body>
        </html>
      HTML
    end

    def generate_styles
      <<~CSS
        <style>
          * { box-sizing: border-box; margin: 0; padding: 0; }

          body {
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
            background: #0d1117;
            color: #e6edf3;
            line-height: 1.6;
            min-height: 100vh;
          }

          .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem 1rem;
          }

          header {
            text-align: center;
            margin-bottom: 2rem;
            padding-bottom: 2rem;
            border-bottom: 1px solid #30363d;
          }

          h1 {
            font-size: 2.5rem;
            font-weight: 700;
            background: linear-gradient(135deg, #58a6ff, #a371f7);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 0.5rem;
          }

          .subtitle {
            color: #8b949e;
            font-size: 1.1rem;
          }

          .search-container {
            margin-bottom: 2rem;
            display: flex;
            gap: 0.75rem;
            align-items: center;
            flex-wrap: wrap;
          }

          .search-input {
            flex: 1;
            max-width: 400px;
            padding: 0.75rem 1rem;
            font-size: 1rem;
            background: #161b22;
            border: 1px solid #30363d;
            border-radius: 8px;
            color: #e6edf3;
            outline: none;
            transition: border-color 0.2s;
          }

          .search-input:focus {
            border-color: #58a6ff;
          }

          .search-input::placeholder {
            color: #6e7681;
          }

          .toggle-all-btn {
            padding: 0.75rem 1rem;
            font-size: 0.875rem;
            background: #161b22;
            border: 1px solid #30363d;
            border-radius: 8px;
            color: #e6edf3;
            cursor: pointer;
            transition: all 0.2s;
            white-space: nowrap;
          }

          .toggle-all-btn:hover {
            border-color: #58a6ff;
            background: #1f242c;
          }

          .game-section {
            margin-bottom: 1.5rem;
            border: 1px solid #30363d;
            border-radius: 12px;
            overflow: hidden;
            background: #161b22;
          }

          .game-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 1rem 1.25rem;
            cursor: pointer;
            user-select: none;
            transition: background 0.2s;
          }

          .game-header:hover {
            background: #1f242c;
          }

          .game-title {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            font-size: 1.25rem;
            font-weight: 600;
          }

          .game-icon {
            font-size: 1.5rem;
          }

          .game-count {
            font-size: 0.875rem;
            color: #8b949e;
            padding: 0.25rem 0.75rem;
            background: #30363d;
            border-radius: 20px;
          }

          .toggle-icon {
            color: #8b949e;
            transition: transform 0.2s;
          }

          .game-section.collapsed .toggle-icon {
            transform: rotate(-90deg);
          }

          .game-section.collapsed .teams-grid {
            display: none;
          }

          .teams-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 0.5rem;
            padding: 0 1rem 1rem;
          }

          .team-card {
            padding: 0.75rem 1rem;
            background: #0d1117;
            border: 1px solid #30363d;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 0.5rem;
          }

          .team-card:hover {
            border-color: var(--accent);
            background: #1a1f26;
          }

          .team-card.copied {
            border-color: #3fb950;
            background: rgba(63, 185, 80, 0.1);
          }

          .team-name {
            font-size: 0.9rem;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
          }

          .copy-icon {
            flex-shrink: 0;
            color: #8b949e;
            opacity: 0;
            transition: opacity 0.2s;
          }

          .team-card:hover .copy-icon {
            opacity: 1;
          }

          .team-card.copied .copy-icon {
            color: #3fb950;
            opacity: 1;
          }

          .hidden {
            display: none !important;
          }

          footer {
            text-align: center;
            margin-top: 3rem;
            padding-top: 2rem;
            border-top: 1px solid #30363d;
            color: #8b949e;
            font-size: 0.875rem;
          }

          footer a {
            color: #58a6ff;
            text-decoration: none;
          }

          footer a:hover {
            text-decoration: underline;
          }

          .toast {
            position: fixed;
            bottom: 2rem;
            left: 50%;
            transform: translateX(-50%) translateY(100px);
            background: #3fb950;
            color: #0d1117;
            padding: 0.75rem 1.5rem;
            border-radius: 8px;
            font-weight: 500;
            opacity: 0;
            transition: all 0.3s;
            z-index: 1000;
          }

          .toast.show {
            transform: translateX(-50%) translateY(0);
            opacity: 1;
          }

          .tutorial {
            margin-bottom: 2rem;
            border: 1px solid #30363d;
            border-radius: 12px;
            background: #161b22;
            overflow: hidden;
          }

          .tutorial-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 1rem 1.25rem;
            cursor: pointer;
            user-select: none;
            transition: background 0.2s;
          }

          .tutorial-header:hover {
            background: #1f242c;
          }

          .tutorial-title {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 1rem;
            font-weight: 600;
            color: #58a6ff;
          }

          .tutorial.collapsed .tutorial-content {
            display: none;
          }

          .tutorial.collapsed .toggle-icon {
            transform: rotate(-90deg);
          }

          .tutorial-content {
            padding: 0 1.25rem 1.25rem;
          }

          .tutorial-steps {
            display: grid;
            gap: 1rem;
          }

          .tutorial-step {
            display: flex;
            gap: 1rem;
            align-items: flex-start;
          }

          .step-number {
            flex-shrink: 0;
            width: 28px;
            height: 28px;
            background: #30363d;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.875rem;
            font-weight: 600;
            color: #58a6ff;
          }

          .step-content h3 {
            font-size: 0.95rem;
            font-weight: 600;
            margin-bottom: 0.25rem;
          }

          .step-content p {
            font-size: 0.875rem;
            color: #8b949e;
          }

          .step-content ul {
            margin-top: 0.5rem;
            padding-left: 1.25rem;
            font-size: 0.875rem;
            color: #8b949e;
          }

          .step-content li {
            margin-bottom: 0.25rem;
          }

          .step-content code {
            background: #0d1117;
            padding: 0.125rem 0.375rem;
            border-radius: 4px;
            font-size: 0.8rem;
            color: #e6edf3;
          }

          @media (max-width: 640px) {
            h1 { font-size: 1.75rem; }
            .teams-grid {
              grid-template-columns: 1fr;
            }
          }
        </style>
      CSS
    end

    def generate_header
      <<~HTML
        <header>
          <h1>Esport ICS Calendars</h1>
          <p class="subtitle">Subscribe to your favorite esports team schedules</p>
        </header>
      HTML
    end

    def generate_tutorial
      <<~HTML
        <div class="tutorial collapsed">
          <div class="tutorial-header" onclick="this.closest('.tutorial').classList.toggle('collapsed')">
            <div class="tutorial-title">
              <span>📖</span>
              <span>How to Subscribe</span>
            </div>
            <svg class="toggle-icon" width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
              <path d="M12.78 5.22a.75.75 0 0 1 0 1.06l-4.25 4.25a.75.75 0 0 1-1.06 0L3.22 6.28a.75.75 0 0 1 1.06-1.06L8 8.94l3.72-3.72a.75.75 0 0 1 1.06 0Z"/>
            </svg>
          </div>
          <div class="tutorial-content">
            <div class="tutorial-steps">
              <div class="tutorial-step">
                <div class="step-number">1</div>
                <div class="step-content">
                  <h3>Copy a calendar URL</h3>
                  <p>Click on any team below to copy its calendar URL to your clipboard.</p>
                </div>
              </div>
              <div class="tutorial-step">
                <div class="step-number">2</div>
                <div class="step-content">
                  <h3>Add to your calendar app</h3>
                  <ul>
                    <li><strong>Google Calendar:</strong> Click <code>+</code> next to "Other calendars" → <code>From URL</code> → Paste</li>
                    <li><strong>Apple Calendar:</strong> <code>File</code> → <code>New Calendar Subscription</code> → Paste</li>
                    <li><strong>Outlook:</strong> <code>Add calendar</code> → <code>Subscribe from web</code> → Paste</li>
                  </ul>
                </div>
              </div>
              <div class="tutorial-step">
                <div class="step-number">3</div>
                <div class="step-content">
                  <h3>Stay updated</h3>
                  <p>Calendars sync automatically. New matches appear as they're scheduled.</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      HTML
    end

    def generate_search
      <<~HTML
        <div class="search-container">
          <input type="text" class="search-input" placeholder="Search teams..." id="search">
          <button class="toggle-all-btn" id="toggleAll" onclick="toggleAllSections()">Expand All</button>
        </div>
      HTML
    end

    def generate_games
      sorted_games = @games.sort_by { |slug, _| GAME_ORDER.index(slug) || 999 }

      sorted_games.map do |game_slug, teams|
        config = GAME_CONFIG[game_slug] || { name: game_slug, accent: "#58a6ff", icon: "🎮" }
        generate_game_section(game_slug, teams, config)
      end.join("\n")
    end

    def generate_game_section(game_slug, teams, config)
      teams_html = teams.map do |team|
        url = "#{GITHUB_RAW_URL}/#{game_slug}/#{team[:slug]}.ics"
        <<~HTML
          <div class="team-card" data-url="#{url}" data-name="#{team[:name].downcase}" style="--accent: #{config[:accent]}">
            <span class="team-name">#{team[:name]}</span>
            <svg class="copy-icon" width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
              <path d="M0 6.75C0 5.784.784 5 1.75 5h1.5a.75.75 0 0 1 0 1.5h-1.5a.25.25 0 0 0-.25.25v7.5c0 .138.112.25.25.25h7.5a.25.25 0 0 0 .25-.25v-1.5a.75.75 0 0 1 1.5 0v1.5A1.75 1.75 0 0 1 9.25 16h-7.5A1.75 1.75 0 0 1 0 14.25Z"/>
              <path d="M5 1.75C5 .784 5.784 0 6.75 0h7.5C15.216 0 16 .784 16 1.75v7.5A1.75 1.75 0 0 1 14.25 11h-7.5A1.75 1.75 0 0 1 5 9.25Zm1.75-.25a.25.25 0 0 0-.25.25v7.5c0 .138.112.25.25.25h7.5a.25.25 0 0 0 .25-.25v-7.5a.25.25 0 0 0-.25-.25Z"/>
            </svg>
          </div>
        HTML
      end.join

      <<~HTML
        <section class="game-section collapsed" data-game="#{game_slug}" style="--accent: #{config[:accent]}">
          <div class="game-header" onclick="toggleSection(this)">
            <div class="game-title">
              <span class="game-icon">#{config[:icon]}</span>
              <span style="color: #{config[:accent]}">#{config[:name]}</span>
            </div>
            <div style="display: flex; align-items: center; gap: 1rem;">
              <span class="game-count">#{teams.size} teams</span>
              <svg class="toggle-icon" width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
                <path d="M12.78 5.22a.75.75 0 0 1 0 1.06l-4.25 4.25a.75.75 0 0 1-1.06 0L3.22 6.28a.75.75 0 0 1 1.06-1.06L8 8.94l3.72-3.72a.75.75 0 0 1 1.06 0Z"/>
              </svg>
            </div>
          </div>
          <div class="teams-grid">
            #{teams_html}
          </div>
        </section>
      HTML
    end

    def generate_footer
      <<~HTML
        <footer>
          <p>Calendars auto-update every 12 hours</p>
          <p>Powered by <a href="https://github.com/snutij/esport_ics" target="_blank">esport_ics</a></p>
        </footer>
        <div class="toast" id="toast">URL copied to clipboard!</div>
      HTML
    end

    def generate_scripts
      <<~HTML
        <script>
          function toggleSection(header) {
            header.closest('.game-section').classList.toggle('collapsed');
            updateToggleAllButton();
          }

          function toggleAllSections() {
            const sections = document.querySelectorAll('.game-section');
            const allCollapsed = [...sections].every(s => s.classList.contains('collapsed'));
            sections.forEach(s => s.classList.toggle('collapsed', !allCollapsed));
            updateToggleAllButton();
          }

          function updateToggleAllButton() {
            const sections = document.querySelectorAll('.game-section');
            const allCollapsed = [...sections].every(s => s.classList.contains('collapsed'));
            document.getElementById('toggleAll').textContent = allCollapsed ? 'Expand All' : 'Collapse All';
          }

          document.querySelectorAll('.team-card').forEach(card => {
            card.addEventListener('click', async () => {
              const url = card.dataset.url;
              try {
                await navigator.clipboard.writeText(url);
                card.classList.add('copied');
                showToast();
                setTimeout(() => card.classList.remove('copied'), 2000);
              } catch (err) {
                prompt('Copy this URL:', url);
              }
            });
          });

          function showToast() {
            const toast = document.getElementById('toast');
            toast.classList.add('show');
            setTimeout(() => toast.classList.remove('show'), 2000);
          }

          document.getElementById('search').addEventListener('input', (e) => {
            const query = e.target.value.toLowerCase().trim();
            const sections = document.querySelectorAll('.game-section');

            sections.forEach(section => {
              const cards = section.querySelectorAll('.team-card');
              let visibleCount = 0;

              cards.forEach(card => {
                const name = card.dataset.name;
                const match = !query || name.includes(query);
                card.classList.toggle('hidden', !match);
                if (match) visibleCount++;
              });

              section.classList.toggle('hidden', visibleCount === 0);
              if (query && visibleCount > 0) {
                section.classList.remove('collapsed');
              }
            });
          });
        </script>
      HTML
    end
  end
end
