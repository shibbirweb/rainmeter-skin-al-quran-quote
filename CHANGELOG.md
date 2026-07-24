# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Settings panel (icon on the main panel) to change the verse appearance and rotation without hand-editing
  files. Changes save to `Variables.inc` and apply immediately. Controls:
  - Font family from a curated, clickable list.
  - Font size via a slider.
  - Font style buttons (Bold / Regular / Italic).
  - Font color and background color via R/G/B(/A) sliders with a live preview swatch.
  - Background opacity via a range slider (click to set, scroll to nudge).
  - Quote change duration (seconds between verses).
- The settings panel's look is defined in its own `Settings/@Resources/SettingsTheme.inc`, kept separate
  from the skin's variables, so editing the skin never restyles the panel.

### Changed

- Split the background `PanelColor` variable into `PanelColorRGB` (color) and `PanelOpacity` (alpha) so
  opacity can be changed independently of the color.
- The verse font style is now driven by a `QuoteStyle` variable (was a hardcoded `StringStyle=Italic`).
- Settings changes apply to the running skin without refetching a new verse (only a rotation-duration
  change refreshes the skin); the settings panel no longer refreshes itself when a value changes.
- The open (main panel) and close (settings panel) controls are drawn as vector shapes instead of font
  glyphs, so they always render correctly regardless of file encoding.

## [1.0.0] - 2026-07-23

### Added

- Initial release of the Al-Quran Quote Rainmeter skin (GitHub issue #1).
- Shows a random Quran verse (Saheeh International English translation) with its reference on a
  minimal, semi-transparent panel.
- Fetches verses live from the quran.com API v4 `verses/random` endpoint.
- Offline fallback: shows a random verse from the bundled `quotes.txt` when there is no connection.
- Left-click for the next verse; automatic rotation on a timer (default every 30 minutes).
- All appearance and timing settings centralized in `@Resources/Variables.inc`.
- `.rmskin` installer built and attached to the GitHub Release automatically via GitHub Actions
  (`.github/workflows/rmskin.yml`).
- `RMSKIN.ini` packaging metadata; it is the single source of truth for the version.
- Developer guide in `docs/DEVELOPER.md`.
