# EsportIcs

This repository automates the generation and updating of an ICS file for a calendar of League of Legends events. Using a GitHub Actions workflow, the calendar is refreshed daily and can be easily subscribed to in Google Calendar, Apple Calendar, and Outlook.

## Subscribing to the ICS Calendar

To subscribe to the ICS calendar, follow these steps:

1. **Get the URL of the ICS file:**

   Find in `ics/league_of_legengs` folder the ICS file that you want to subscribe, than click on `raw` button, and pick the URL, e.g:

   ```
   https://raw.githubusercontent.com/snutij/esport_ics/main/ics/league_of_legends/LEC.ics
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
