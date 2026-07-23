# Al-Quran Quote

A minimal [Rainmeter](https://www.rainmeter.net) skin for Windows that shows a random verse from the
Holy Quran (Sahih International English translation) with its reference. Click it for the next verse;
it also rotates on a timer.

![mockup](docs/mockup.png)

## Features

- Random verse fetched live from the free [quran.com API v4](https://api-docs.quran.com).
- Offline fallback: if there is no internet, a verse from a bundled list is shown instead.
- Click anywhere on the panel for the next verse; auto-rotates every 30 minutes by default.
- Small, self-contained panel (no bundled fonts or images). Fully themeable.

## Install

1. Install Rainmeter from https://www.rainmeter.net.
2. Copy the `AlQuranQuote` folder into your Rainmeter skins folder
   (usually `Documents\Rainmeter\Skins\`).
3. Open Rainmeter, click **Refresh all**, then load `AlQuranQuote\AlQuranQuote.ini`.

## Configure

All settings live in `AlQuranQuote\@Resources\Variables.inc`. Edit and refresh the skin.

- `RotateEvery` - seconds between automatic verse changes (default 1800 = 30 min).
- `PanelWidth`, `Pad`, `Radius` - panel size and corner rounding.
- `QuoteFont`, `RefFont`, `QuoteSize`, `RefSize` - fonts and sizes.
- `QuoteColor`, `RefColor`, `PanelColor`, `PanelBorder` - colors (R,G,B,A).

## Add an offline verse

Append a line to `AlQuranQuote\@Resources\quotes.txt` in the form:

```
English translation text | Quran X:Y
```

## Credits

- Verse data: [quran.com API](https://quran.com) (Sahih International translation).
- License: MIT (see [LICENSE](LICENSE)).
