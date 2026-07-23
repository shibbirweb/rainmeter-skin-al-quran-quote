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

Easiest: download the `.rmskin` from the [Releases](../../releases) page and double-click it.

Manual:

1. Install Rainmeter from https://www.rainmeter.net.
2. Copy `Skins/AlQuranQuote` from this repo into your Rainmeter skins folder
   (usually `Documents\Rainmeter\Skins\`).
3. Open Rainmeter, click **Refresh all**, then load `AlQuranQuote\AlQuranQuote.ini`.

## Configure

All settings live in `Skins/AlQuranQuote/@Resources/Variables.inc`. Edit and refresh the skin.

- `RotateEvery` - seconds between automatic verse changes (default 1800 = 30 min).
- `PanelWidth`, `Pad`, `Radius` - panel size and corner rounding.
- `QuoteFont`, `RefFont`, `QuoteSize`, `RefSize` - fonts and sizes.
- `QuoteColor`, `RefColor`, `PanelColor`, `PanelBorder` - colors (R,G,B,A).

## Add an offline verse

Append a line to `Skins/AlQuranQuote/@Resources/quotes.txt` in the form:

```
English translation text | Quran X:Y
```

## Release

The `.rmskin` installer is built automatically by GitHub Actions
([`.github/workflows/rmskin.yml`](.github/workflows/rmskin.yml)) using
[2bndy5/rmskin-action](https://github.com/2bndy5/rmskin-action), which reads `RMSKIN.ini` and the
`Skins/` folder. To cut a release:

1. Bump the version in `RMSKIN.ini` (the single source of truth) and add a matching `CHANGELOG.md`
   section. You do not edit the skin's `[Metadata]` version; CI stamps it from `RMSKIN.ini`.
2. Tag with the same version and push: `git tag v1.0.0 && git push origin v1.0.0`.
3. The workflow verifies the tag matches `RMSKIN.ini`, builds the `.rmskin`, and attaches it to the
   GitHub Release for that tag. (You can also run the workflow manually from the Actions tab to get a
   build artifact without releasing.)

## Contributing

See the [Developer Guide](docs/DEVELOPER.md) for architecture, local setup, debugging, and the
release process.

## Credits

- Verse data: [quran.com API](https://quran.com) (Saheeh International translation).
- License: MIT (see [LICENSE](LICENSE)).
