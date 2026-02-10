# EsportIcs

This repository automates the generation and update of ICS files for esport events. Calendars are refreshed daily and can be subscribed to in Google Calendar, Apple Calendar and Outlook.

## Web Interface

Browse all calendars at: https://esport-ics.pages.dev

## Supported Games

- [Call of Duty MW](ics/call_of_duty_mw/)
- [Counter-Strike 2](ics/counter_strike/)
- [Dota 2](ics/dota_2/)
- [EA Sports FC](ics/ea_sports_fc/)
- [King of Glory](ics/king_of_glory/)
- [League of Legends](ics/league_of_legends/)
- [League of Legends WildRift](ics/league_of_legends_wildrift/)
- [Mobile Legends: Bang Bang](ics/mobile_legends/)
- [Overwatch 2](ics/overwatch_2/)
- [PUBG](ics/pubg/)
- [Rainbow Six Siege](ics/rainbow_six_siege/)
- [Rocket League](ics/rocket_league/)
- [StarCraft 2](ics/starcraft_2/)
- [StarCraft: Brood War](ics/starcraft_brood_war/)
- [Valorant](ics/valorant/)

All games available on the [PandaScore API](https://pandascore.co/) are supported. If you'd like to see a new game added, please open an issue or submit a pull request.

## Subscribing to the ICS Calendar

To subscribe to an ICS calendar, follow these steps:

1. **Get the URL of the ICS file:**

   Find in the `ics/league_of_legends` folder the ICS file for the team that you want to subscribe to, then click on the `raw` button, and pick the URL, e.g.:

   ```
   https://raw.githubusercontent.com/snutij/esport_ics/main/ics/league_of_legends/karmine-corp.ics
   ```

2. **Subscribe using Google Calendar:**

   - Open Google Calendar.
   - On the left side, click the **+** next to "Other calendars".
   - Select **From URL**.
   - Paste the URL of the ICS file.
   - Click **Add calendar**.
   - You can rename it within calendar options

3. **Subscribe using Apple Calendar:**

   - Open Apple Calendar.
   - Go to **File > New Calendar Subscription**.
   - Paste the URL of the ICS file.
   - Click **Subscribe**.
   - Adjust the settings as needed and click **OK**.

4. **Subscribe using Outlook:**

   - Open Outlook.
   - Go to **File > Account Settings > Account Settings**.
   - Go to the **Internet Calendars** tab.
   - Click **New**.
   - Paste the URL of the ICS file.
   - Click **Add**.
   - Adjust the settings as needed and click **OK**.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Disclaimer

The data used to generate the ICS files comes from [pandascore](https://pandascore.co/). I am not responsible for any inaccuracies or errors in the information provided in the generated ICS files. Please verify the information independently if accuracy is critical.

Btw, special thanks to them for offering a generous free tier, which has played a crucial role in the development of this project.
