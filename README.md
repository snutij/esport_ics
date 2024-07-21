# EsportIcs

This repository automates the generation and update of ICS files for esport events. Calendars are refreshed daily and can be subscribed to in Google Calendar, Apple Calendar and Outlook.

## Supported Games

- [Call of Duty MW](ics/call_of_duty_mw/)
- [Dota 2](ics/dota_2/)
- [Counter-Strike: Global Offensive](ics/counter_strike)
- [League of Legends](ics/league_of_legends/)
- [League of Legends WildRift](ics/league_of_legends_wildrift/)
- [Overwatch 2](ics/overwatch_2)
- [Rainbow Six Siege](ics/rainbow_six_siege)
- [Valorant](ics/valorant)

While my personal interest is primarily on League of Legends, I'm open to expanding the list of supported games based on community interest. If there's a particular game you'd like to see supported, please let me know by opening an issue or submitting a pull request.

## Subscribing to the ICS Calendar

To subscribe to an ICS calendar, follow these steps:

1. **Get the URL of the ICS file:**

   Find in the `ics/league_of_legengs` folder the ICS file for the team that you want to subscribe to, then click on the `raw` button, and pick the URL, e.g.:

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
