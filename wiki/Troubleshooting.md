# Troubleshooting

Quick fixes for the most common issues. If none of these help, please open an issue on the
[project page](https://github.com/shibbirweb/rainmeter-skin-al-quran-quote/issues).

## The panel is stuck on "Loading verse..."

This usually means an online fetch is not completing.

- **Easiest fix:** turn **Online fetch** off on the Verse tab. The skin will use the offline list and show
  a verse immediately.
- If you want online verses, check that your internet connection is working.
- Corporate or school networks with special proxy settings can occasionally block the request. The offline
  list always works regardless.

## I don't see the settings icon

The icon can be hidden (there is a checkbox for it on the Panel tab). To reopen settings:

1. Open **Rainmeter** (system tray icon).
2. Click **Manage**.
3. In the list, find and load **`AlQuranQuote\Settings`**.

The settings panel reappears. You can re-tick **Show settings icon** there if you want it back on the
panel.

## The verse shows boxes, question marks, or blank text

The font you chose does not contain the characters for that language (common when switching to Arabic or
another script).

- Go to the **Text** tab and choose a font that supports the script.
- For Arabic, try an Arabic font such as *Traditional Arabic* or *Amiri*.

See **[Languages](Languages)**.

## The verse text is cut off or the panel is too small

- Make sure **height** is set to **automatic** on the Panel tab. Automatic height grows to fit long
  verses.
- If you use a fixed height, increase the value or switch back to automatic.

## Nothing appears after I double-clicked the .rmskin file

- Make sure **Rainmeter itself** is installed first (from [rainmeter.net](https://www.rainmeter.net)). The
  `.rmskin` file needs Rainmeter to open it.
- After installing, open Rainmeter, click **Refresh all**, and load **`AlQuranQuote\AlQuranQuote.ini`**.

## My changes are not taking effect

- Settings apply immediately. If something looks off, try the **Reset** button on the Verse tab to return
  to defaults, then re-apply your changes.
- As a last resort, right-click the panel and choose **Refresh skin**.

## Checking the log for errors (advanced)

Rainmeter keeps a log that can explain unusual problems:

1. Open Rainmeter and click **About**.
2. Go to the **Log** tab.
3. Look for red error lines around the time the problem happened.

If you report an issue, including a copy of these log lines helps a lot.

---

Back to **[Home](Home)**.
