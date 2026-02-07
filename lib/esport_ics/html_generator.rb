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
      "call_of_duty_mw" => { name: "Call of Duty", accent: "#f6a800" },
      "counter_strike" => { name: "Counter-Strike 2", accent: "#de9b35" },
      "dota_2" => { name: "Dota 2", accent: "#e8503b" },
      "league_of_legends" => { name: "League of Legends", accent: "#c9aa71" },
      "league_of_legends_wildrift" => { name: "LoL Wild Rift", accent: "#1ca5b8" },
      "overwatch_2" => { name: "Overwatch 2", accent: "#fa9c1e" },
      "rainbow_six_siege" => { name: "Rainbow Six Siege", accent: "#8a8a8a" },
      "rocket_league" => { name: "Rocket League", accent: "#0088e0" },
      "valorant" => { name: "Valorant", accent: "#ff4655" },
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
          <title>Esport ICS Calendars — Free Esports Schedules for Google Calendar, Apple Calendar & Outlook</title>
          <meta name="description" content="Free ICS calendar subscriptions for esports teams. Track schedules for League of Legends, Counter-Strike, Valorant, Dota 2 and more in Google Calendar, Apple Calendar or Outlook.">
          <link rel="canonical" href="https://esport-ics.pages.dev/">
          <meta name="robots" content="index, follow">
          <meta name="theme-color" content="#06080c">
          <link rel="preconnect" href="https://fonts.googleapis.com">
          <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
          <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@700&family=Exo+2:wght@400;600&display=swap" rel="stylesheet">
          <meta property="og:title" content="Esport ICS Calendars">
          <meta property="og:description" content="Free ICS calendar subscriptions for esports. Track your favorite teams in any calendar app.">
          <meta property="og:type" content="website">
          <meta property="og:url" content="https://esport-ics.pages.dev/">
          <meta name="twitter:card" content="summary">
          <meta name="twitter:title" content="Esport ICS Calendars">
          <meta name="twitter:description" content="Free ICS calendar subscriptions for esports. Track your favorite teams in any calendar app.">
          <script type="application/ld+json">
          {
            "@context": "https://schema.org",
            "@type": "WebSite",
            "name": "Esport ICS Calendars",
            "url": "https://esport-ics.pages.dev/",
            "description": "Free ICS calendar subscriptions for esports teams."
          }
          </script>
          #{generate_styles}
        </head>
        <body>
          <div class="container">
            #{generate_header}
            #{generate_tutorial}
            <main>
            #{generate_search}
            #{generate_games}
            </main>
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

          :root {
            --bg-deep: #06080c;
            --bg-mid: #0a0e14;
            --bg-surface: #111820;
            --bg-elevated: #161d28;
            --border: rgba(255, 255, 255, 0.06);
            --border-hover: rgba(255, 255, 255, 0.12);
            --text: #e0e6ed;
            --text-muted: #6b7a8d;
            --cyan: #00e5ff;
            --success: #3fb950;
          }

          body {
            font-family: 'Exo 2', 'Segoe UI', system-ui, sans-serif;
            background: var(--bg-deep);
            color: var(--text);
            line-height: 1.6;
            min-height: 100vh;
            position: relative;
          }

          body::before {
            content: '';
            position: fixed;
            inset: 0;
            background:
              linear-gradient(rgba(255,255,255,0.015) 1px, transparent 1px),
              linear-gradient(90deg, rgba(255,255,255,0.015) 1px, transparent 1px);
            background-size: 60px 60px;
            pointer-events: none;
            z-index: 0;
          }

          .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem 1rem;
            position: relative;
            z-index: 1;
          }

          /* --- Typography --- */
          h1, h2, .game-title h2 {
            font-family: 'Rajdhani', 'Segoe UI', sans-serif;
            text-transform: uppercase;
            letter-spacing: 0.04em;
          }

          /* --- Header --- */
          header {
            text-align: center;
            margin-bottom: 2.5rem;
            padding-bottom: 2.5rem;
            border-bottom: 1px solid var(--border);
            position: relative;
          }

          .header-title-wrap {
            display: inline-block;
            position: relative;
            padding-bottom: 0.35rem;
          }

          .header-title-wrap::before {
            content: '';
            position: absolute;
            inset: 0;
            background: repeating-linear-gradient(
              0deg,
              transparent,
              transparent 2px,
              rgba(255,255,255,0.02) 2px,
              rgba(255,255,255,0.02) 4px
            );
            pointer-events: none;
          }

          .header-title-wrap::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 50%;
            transform: translateX(-50%);
            height: 2px;
            background: var(--cyan);
            box-shadow: 0 0 12px var(--cyan), 0 0 30px rgba(0,229,255,0.3);
            animation: neon-line 0.8s ease-out forwards;
            width: 0;
          }

          @keyframes neon-line {
            to { width: 100%; }
          }

          .github-link {
            position: absolute;
            top: 0;
            right: 0;
            color: var(--text-muted);
            transition: color 0.2s, filter 0.2s;
          }

          .github-link:hover {
            color: var(--text);
            filter: drop-shadow(0 0 4px rgba(255,255,255,0.3));
          }

          h1 {
            font-size: 2.8rem;
            font-weight: 700;
            background: linear-gradient(135deg, #00e5ff, #a371f7);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 0.5rem;
          }

          .subtitle {
            color: var(--text-muted);
            font-size: 1.05rem;
            font-weight: 400;
            letter-spacing: 0.03em;
          }

          /* --- Search --- */
          .search-container {
            margin-bottom: 2rem;
            display: flex;
            gap: 0.75rem;
            align-items: center;
            flex-wrap: wrap;
          }

          .search-input {
            flex: 1;
            max-width: 420px;
            padding: 0.75rem 1.1rem;
            font-family: 'Exo 2', sans-serif;
            font-size: 0.95rem;
            background: var(--bg-surface);
            border: 1px solid var(--border);
            color: var(--text);
            outline: none;
            transition: border-color 0.2s, box-shadow 0.2s;
            clip-path: polygon(0 0, calc(100% - 12px) 0, 100% 12px, 100% 100%, 0 100%);
          }

          .search-input:focus {
            border-color: var(--cyan);
            box-shadow: 0 0 0 2px rgba(0, 229, 255, 0.15), 0 0 20px rgba(0, 229, 255, 0.1);
          }

          .search-input::placeholder {
            color: var(--text-muted);
          }

          .toggle-all-btn {
            padding: 0.75rem 1.1rem;
            font-family: 'Exo 2', sans-serif;
            font-size: 0.85rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            background: var(--bg-surface);
            border: 1px solid var(--border);
            color: var(--text);
            cursor: pointer;
            transition: all 0.2s;
            white-space: nowrap;
            clip-path: polygon(12px 0, 100% 0, 100% 100%, 0 100%, 0 12px);
          }

          .toggle-all-btn:hover {
            border-color: var(--cyan);
            background: var(--bg-elevated);
            box-shadow: 0 0 12px rgba(0, 229, 255, 0.1);
          }

          /* --- Game Sections --- */
          .game-section {
            margin-bottom: 1.25rem;
            border: 1px solid var(--border);
            border-left: 4px solid var(--accent, var(--cyan));
            overflow: hidden;
            background: var(--bg-mid);
            clip-path: polygon(0 0, calc(100% - 16px) 0, 100% 16px, 100% 100%, 16px 100%, 0 calc(100% - 16px));
            box-shadow: -4px 0 20px -6px var(--accent, var(--cyan));
            opacity: 0;
            transform: translateY(20px);
            transition: opacity 0.5s ease, transform 0.5s ease;
          }

          .game-section.revealed {
            opacity: 1;
            transform: translateY(0);
          }

          .game-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 1rem 1.25rem;
            cursor: pointer;
            user-select: none;
            transition: background 0.2s;
            position: relative;
          }

          .game-header::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            bottom: 0;
            width: 0;
            background: linear-gradient(90deg, rgba(var(--accent-rgb, 0,229,255), 0.08), transparent);
            transition: width 0.3s;
          }

          .game-header:hover {
            background: var(--bg-surface);
          }

          .game-header:hover::before {
            width: 100%;
          }

          .game-title {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            font-size: 1.25rem;
            font-weight: 700;
          }

          .accent-bar {
            width: 4px;
            height: 24px;
            background: var(--accent, var(--cyan));
            box-shadow: 0 0 8px var(--accent, var(--cyan));
          }

          .game-title h2 {
            font-size: 1.2rem;
            font-weight: 700;
            margin: 0;
          }

          .game-count {
            font-size: 0.8rem;
            font-weight: 600;
            color: var(--text-muted);
            padding: 0.2rem 0.6rem;
            background: var(--bg-surface);
            border: 1px solid var(--border);
            clip-path: polygon(6px 0, 100% 0, calc(100% - 6px) 100%, 0 100%);
          }

          .toggle-icon {
            color: var(--text-muted);
            transition: transform 0.3s ease;
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
            list-style: none;
          }

          /* --- Team Cards --- */
          .team-card {
            padding: 0.65rem 0.9rem;
            background: var(--bg-deep);
            border: 1px solid var(--border);
            border-left: 3px solid var(--accent, var(--cyan));
            cursor: pointer;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 0.5rem;
            clip-path: polygon(0 0, 100% 0, 100% calc(100% - 8px), calc(100% - 8px) 100%, 0 100%);
            opacity: 0;
            transform: translateY(10px);
          }

          .team-card.animate-in {
            animation: card-appear 0.2s ease forwards;
          }

          @keyframes card-appear {
            to {
              opacity: 1;
              transform: translateY(0);
            }
          }

          .team-card:hover {
            border-color: var(--accent, var(--cyan));
            background: var(--bg-surface);
            box-shadow: 0 0 16px -4px var(--accent, var(--cyan)), inset 0 0 20px -12px var(--accent, var(--cyan));
          }

          .team-card.copied {
            border-color: var(--success);
            background: rgba(63, 185, 80, 0.08);
            box-shadow: 0 0 16px -4px var(--success);
          }

          .team-name {
            font-size: 0.875rem;
            font-weight: 600;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
          }

          .copy-icon {
            flex-shrink: 0;
            color: var(--text-muted);
            opacity: 0;
            transition: opacity 0.2s;
          }

          .team-card:hover .copy-icon {
            opacity: 1;
          }

          .team-card.copied .copy-icon {
            color: var(--success);
            opacity: 1;
          }

          .hidden {
            display: none !important;
          }

          /* --- Footer --- */
          footer {
            text-align: center;
            margin-top: 3rem;
            padding-top: 2rem;
            border-top: 1px solid var(--border);
            color: var(--text-muted);
            font-size: 0.85rem;
          }

          footer a {
            color: var(--cyan);
            text-decoration: none;
            transition: text-shadow 0.2s;
          }

          footer a:hover {
            text-decoration: underline;
            text-shadow: 0 0 8px rgba(0, 229, 255, 0.4);
          }

          /* --- Toast --- */
          .toast {
            position: fixed;
            bottom: 2rem;
            left: 50%;
            transform: translateX(-50%) translateY(100px);
            background: var(--success);
            color: var(--bg-deep);
            padding: 0.75rem 1.5rem;
            font-family: 'Exo 2', sans-serif;
            font-weight: 600;
            opacity: 0;
            transition: all 0.3s;
            z-index: 1000;
            clip-path: polygon(8px 0, calc(100% - 8px) 0, 100% 8px, 100% 100%, calc(100% - 8px) 100%, 8px 100%, 0 100%, 0 8px);
          }

          .toast.show {
            transform: translateX(-50%) translateY(0);
            opacity: 1;
          }

          /* --- Tutorial --- */
          .tutorial {
            margin-bottom: 2rem;
            border: 1px solid var(--border);
            border-left: 4px solid var(--cyan);
            background: var(--bg-mid);
            overflow: hidden;
            clip-path: polygon(0 0, calc(100% - 12px) 0, 100% 12px, 100% 100%, 12px 100%, 0 calc(100% - 12px));
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
            background: var(--bg-surface);
          }

          .tutorial-title {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-family: 'Rajdhani', sans-serif;
            font-size: 1.05rem;
            font-weight: 700;
            color: var(--cyan);
            text-transform: uppercase;
            letter-spacing: 0.05em;
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
            background: var(--bg-surface);
            border: 1px solid var(--cyan);
            clip-path: polygon(4px 0, 100% 0, calc(100% - 4px) 100%, 0 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Rajdhani', sans-serif;
            font-size: 0.9rem;
            font-weight: 700;
            color: var(--cyan);
          }

          .step-content h3 {
            font-family: 'Rajdhani', sans-serif;
            font-size: 1rem;
            font-weight: 700;
            margin-bottom: 0.25rem;
            text-transform: uppercase;
            letter-spacing: 0.03em;
          }

          .step-content p {
            font-size: 0.875rem;
            color: var(--text-muted);
          }

          .step-content ul {
            margin-top: 0.5rem;
            padding-left: 1.25rem;
            font-size: 0.875rem;
            color: var(--text-muted);
          }

          .step-content li {
            margin-bottom: 0.25rem;
          }

          .step-content code {
            background: var(--bg-deep);
            padding: 0.125rem 0.375rem;
            font-size: 0.8rem;
            color: var(--cyan);
            border: 1px solid var(--border);
          }

          /* --- Responsive --- */
          @media (max-width: 640px) {
            h1 { font-size: 1.85rem; }
            .teams-grid {
              grid-template-columns: 1fr;
            }
            .game-section {
              clip-path: polygon(0 0, calc(100% - 10px) 0, 100% 10px, 100% 100%, 10px 100%, 0 calc(100% - 10px));
            }
            .team-card {
              clip-path: polygon(0 0, 100% 0, 100% calc(100% - 6px), calc(100% - 6px) 100%, 0 100%);
            }
            .tutorial {
              clip-path: polygon(0 0, calc(100% - 8px) 0, 100% 8px, 100% 100%, 8px 100%, 0 calc(100% - 8px));
            }
          }
        </style>
      CSS
    end

    def generate_header
      <<~HTML
        <header>
          <a href="https://github.com/snutij/esport_ics" target="_blank" rel="noopener noreferrer" class="github-link" aria-label="View on GitHub">
            <svg width="32" height="32" viewBox="0 0 16 16" fill="currentColor">
              <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"/>
            </svg>
          </a>
          <div class="header-title-wrap">
            <h1>Esport ICS Calendars</h1>
          </div>
          <p class="subtitle">Subscribe to your favorite esports team schedules</p>
        </header>
      HTML
    end

    def generate_tutorial
      <<~HTML
        <section class="tutorial collapsed">
          <div class="tutorial-header" role="button" tabindex="0" aria-expanded="false" onclick="toggleTutorial(this)">
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
        </section>
      HTML
    end

    def generate_search
      <<~HTML
        <div class="search-container" role="search">
          <input type="text" class="search-input" placeholder="Search teams..." id="search">
          <button class="toggle-all-btn" id="toggleAll" onclick="toggleAllSections()">Expand All</button>
        </div>
      HTML
    end

    def generate_games
      sorted_games = @games.sort_by { |slug, _| GAME_ORDER.index(slug) || 999 }

      sorted_games.map do |game_slug, teams|
        config = GAME_CONFIG[game_slug] || { name: game_slug, accent: "#58a6ff" }
        generate_game_section(game_slug, teams, config)
      end.join("\n")
    end

    def generate_game_section(game_slug, teams, config)
      teams_html = teams.map do |team|
        url = "#{GITHUB_RAW_URL}/#{game_slug}/#{team[:slug]}.ics"
        <<~HTML
          <li class="team-card" role="button" tabindex="0" data-url="#{url}" data-name="#{team[:name].downcase}" style="--accent: #{config[:accent]}">
            <span class="team-name">#{team[:name]}</span>
            <svg class="copy-icon" width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
              <path d="M0 6.75C0 5.784.784 5 1.75 5h1.5a.75.75 0 0 1 0 1.5h-1.5a.25.25 0 0 0-.25.25v7.5c0 .138.112.25.25.25h7.5a.25.25 0 0 0 .25-.25v-1.5a.75.75 0 0 1 1.5 0v1.5A1.75 1.75 0 0 1 9.25 16h-7.5A1.75 1.75 0 0 1 0 14.25Z"/>
              <path d="M5 1.75C5 .784 5.784 0 6.75 0h7.5C15.216 0 16 .784 16 1.75v7.5A1.75 1.75 0 0 1 14.25 11h-7.5A1.75 1.75 0 0 1 5 9.25Zm1.75-.25a.25.25 0 0 0-.25.25v7.5c0 .138.112.25.25.25h7.5a.25.25 0 0 0 .25-.25v-7.5a.25.25 0 0 0-.25-.25Z"/>
            </svg>
          </li>
        HTML
      end.join

      <<~HTML
        <section class="game-section collapsed" data-game="#{game_slug}" style="--accent: #{config[:accent]}">
          <div class="game-header" role="button" tabindex="0" aria-expanded="false" onclick="toggleSection(this)">
            <div class="game-title">
              <span class="accent-bar" style="background: #{config[:accent]}; box-shadow: 0 0 8px #{config[:accent]}"></span>
              <h2 style="color: #{config[:accent]}">#{config[:name]}</h2>
            </div>
            <div style="display: flex; align-items: center; gap: 1rem;">
              <span class="game-count">#{teams.size} teams</span>
              <svg class="toggle-icon" width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
                <path d="M12.78 5.22a.75.75 0 0 1 0 1.06l-4.25 4.25a.75.75 0 0 1-1.06 0L3.22 6.28a.75.75 0 0 1 1.06-1.06L8 8.94l3.72-3.72a.75.75 0 0 1 1.06 0Z"/>
              </svg>
            </div>
          </div>
          <ul class="teams-grid">
            #{teams_html}
          </ul>
        </section>
      HTML
    end

    def generate_footer
      <<~HTML
        <footer>
          <p>Calendars auto-update every 12 hours</p>
          <p>Powered by <a href="https://github.com/snutij/esport_ics" target="_blank" rel="noopener noreferrer">esport_ics</a></p>
        </footer>
        <div class="toast" id="toast">URL copied to clipboard!</div>
      HTML
    end

    def generate_scripts
      <<~HTML
        <script>
          function animateCards(section) {
            const cards = section.querySelectorAll('.team-card');
            cards.forEach((card, i) => {
              card.classList.remove('animate-in');
              card.style.opacity = '0';
              card.style.transform = 'translateY(10px)';
              requestAnimationFrame(() => {
                card.style.animationDelay = (i * 15) + 'ms';
                card.classList.add('animate-in');
              });
            });
          }

          function toggleSection(header) {
            const section = header.closest('.game-section');
            const wasCollapsed = section.classList.contains('collapsed');
            section.classList.toggle('collapsed');
            const expanded = !section.classList.contains('collapsed');
            header.setAttribute('aria-expanded', expanded);
            if (wasCollapsed) animateCards(section);
            updateToggleAllButton();
          }

          function toggleTutorial(header) {
            const tutorial = header.closest('.tutorial');
            tutorial.classList.toggle('collapsed');
            const expanded = !tutorial.classList.contains('collapsed');
            header.setAttribute('aria-expanded', expanded);
          }

          function toggleAllSections() {
            const sections = document.querySelectorAll('.game-section');
            const allCollapsed = [...sections].every(s => s.classList.contains('collapsed'));
            sections.forEach((s, idx) => {
              s.classList.toggle('collapsed', !allCollapsed);
              const header = s.querySelector('.game-header');
              if (header) header.setAttribute('aria-expanded', allCollapsed);
              if (allCollapsed) {
                setTimeout(() => animateCards(s), idx * 40);
              }
            });
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

          function filterTeams(query) {
            const sections = document.querySelectorAll('.game-section');

            sections.forEach(section => {
              const cards = section.querySelectorAll('.team-card');
              let visibleCount = 0;

              cards.forEach(card => {
                const name = card.dataset.name;
                const match = !query || name.includes(query);
                card.classList.toggle('hidden', !match);
                if (match) {
                  visibleCount++;
                  if (query) {
                    card.classList.remove('animate-in');
                    card.style.opacity = '1';
                    card.style.transform = 'none';
                  }
                }
              });

              section.classList.toggle('hidden', visibleCount === 0);
              if (query && visibleCount > 0) {
                section.classList.remove('collapsed');
                const header = section.querySelector('.game-header');
                if (header) header.setAttribute('aria-expanded', 'true');
              }
            });
          }

          document.getElementById('search').addEventListener('input', (e) => {
            const query = e.target.value.toLowerCase().trim();
            filterTeams(query);
            const url = new URL(window.location);
            if (query) {
              url.searchParams.set('search', query);
            } else {
              url.searchParams.delete('search');
            }
            history.replaceState(null, '', url);
          });

          const initialSearch = new URLSearchParams(window.location.search).get('search');
          if (initialSearch) {
            const searchInput = document.getElementById('search');
            searchInput.value = initialSearch;
            filterTeams(initialSearch.toLowerCase().trim());
          }

          // Scroll-triggered reveal
          const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
              if (entry.isIntersecting) {
                entry.target.classList.add('revealed');
                observer.unobserve(entry.target);
              }
            });
          }, { threshold: 0.1, rootMargin: '0px 0px -40px 0px' });

          document.querySelectorAll('.game-section').forEach((section, i) => {
            section.style.transitionDelay = (i * 80) + 'ms';
            observer.observe(section);
          });
        </script>
      HTML
    end
  end
end
