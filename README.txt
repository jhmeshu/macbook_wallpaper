COMPANY WALLPAPER - TEST PACKAGE

Wallpaper URL:
https://images.pexels.com/photos/30784971/pexels-photo-30784971.jpeg

IMPORTANT:
1. Upload config.json to a public HTTPS location that your Macs can reach.
2. Edit company_wallpaper.sh and replace:
   CONFIG_URL="https://YOUR-CONFIG-URL.example.com/config.json"
   with the real URL.
3. Do NOT use the Pexels image URL as your config URL. It is the wallpaper image URL.
4. This package is intended for testing on one Mac first.

config.json currently contains:
{
  "version": 1,
  "url": "https://images.pexels.com/photos/30784971/pexels-photo-30784971.jpeg"
}

Manual test:
sudo mkdir -p /Library/Scripts
sudo cp company_wallpaper.sh /Library/Scripts/company_wallpaper.sh
sudo chmod 755 /Library/Scripts/company_wallpaper.sh
sudo chown root:wheel /Library/Scripts/company_wallpaper.sh

Then test:
sudo /Library/Scripts/company_wallpaper.sh

For LaunchDaemon:
sudo cp com.company.wallpaper.plist /Library/LaunchDaemons/
sudo chown root:wheel /Library/LaunchDaemons/com.company.wallpaper.plist
sudo chmod 644 /Library/LaunchDaemons/com.company.wallpaper.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/com.company.wallpaper.plist

To check:
sudo launchctl print system/com.company.wallpaper

NOTE:
The script uses osascript from a LaunchDaemon to change the logged-in user's wallpaper.
Modern macOS privacy/session security can prevent this in some environments.
If that happens, the next version should use a per-user LaunchAgent for the GUI wallpaper change.
