<h1 align="center">Esport ICS</h1>

<p align="center">
  ICS calendar subscriptions for esports teams.<br>
  Updated hourly. Free & open source.
</p>

<p align="center">
  <a href="https://esport-ics.pages.dev"><strong>Browse calendars &rarr;</strong></a>
</p>

<p align="center">
  <a href="https://github.com/snutij/esport_ics/actions/workflows/update_ics.yml"><img src="https://github.com/snutij/esport_ics/actions/workflows/update_ics.yml/badge.svg" alt="Update ICS Calendar"></a>&nbsp;
  <a href="LICENSE.txt"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License"></a>&nbsp;
  <a href="https://pandascore.co/"><img src="https://img.shields.io/badge/data-PandaScore-orange.svg" alt="PandaScore"></a>
</p>

---

## Supported Games

- Call of Duty MW
- Counter-Strike 2
- Dota 2
- EA Sports FC
- King of Glory
- League of Legends
- League of Legends: Wild Rift
- Mobile Legends: Bang Bang
- Overwatch 2
- PUBG
- Rainbow Six Siege
- Rocket League
- StarCraft 2
- StarCraft: Brood War
- Valorant

All games available on the [PandaScore API](https://pandascore.co/) are supported.
Missing a game? [Open an issue](https://github.com/snutij/esport_ics/issues/new).

## Subscribe to a Calendar

Grab the raw URL for any team's `.ics` file:

```
https://raw.githubusercontent.com/snutij/esport_ics/main/ics/league_of_legends/karmine-corp.ics
```

Or browse the full list on the [web interface](https://esport-ics.pages.dev) and copy the link from there.

<details>
<summary><strong>Google Calendar</strong></summary>

1. Click **+** next to "Other calendars"
2. Select **From URL**
3. Paste the `.ics` URL
4. Click **Add calendar**
</details>

<details>
<summary><strong>Apple Calendar</strong></summary>

1. **File → New Calendar Subscription**
2. Paste the `.ics` URL
3. Click **Subscribe**, adjust settings, **OK**
</details>

<details>
<summary><strong>Outlook</strong></summary>

1. **File → Account Settings → Account Settings**
2. **Internet Calendars** tab → **New**
3. Paste the `.ics` URL → **Add** → **OK**
</details>

## How It Works

A GitHub Actions cron job runs every hour:

1. Fetches upcoming matches from the [PandaScore API](https://pandascore.co/)
2. Generates one `.ics` file per team, per game
3. Commits updated files to `ics/`
4. The [web interface](https://esport-ics.pages.dev) is deployed on Cloudflare Pages

The Ruby codebase lives in `lib/esport_ics/`. Run `bundle exec rake` for tests and linting.

## Contributing

Contributions welcome — open an issue or submit a PR.

## License

[MIT](LICENSE.txt)

## Disclaimer

Match data comes from [PandaScore](https://pandascore.co/). Verify independently if accuracy is critical. Special thanks to PandaScore for their generous free tier.
