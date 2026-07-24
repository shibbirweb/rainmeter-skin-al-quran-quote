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
  - Font family from a curated list, with an option to type any font name directly.
  - Font color and background color via R/G/B(/A) sliders with a live preview swatch; font color,
    background color, and opacity can also be typed directly.
  - Background opacity via a range slider (click to set, scroll to nudge).
  - Quote change duration (seconds between verses).
  - Panel width: automatic, or a fixed pixel width.
  - Panel height: automatic (grows to fit), or a fixed pixel height.
  - Automatic rotation on/off (when off, the verse stays until you fetch the next one).
  - Editable reference label (the text before the verse key), default "Al Quran".
  - Rounded border opacity.
  - Show or hide the settings icon on the quote window (when hidden, reopen the settings skin from
    Rainmeter's Manage dialog).
  - Reset all settings to their defaults.
- A small next-verse control next to the reference fetches the next verse.
- The settings panel's look is defined in its own `Settings/@Resources/SettingsTheme.inc`, kept separate
  from the skin's variables, so editing the skin never restyles the panel.
- Author website URL (https://shibbirweb.github.io) in the `[Metadata] Information` of both the main skin
  and the settings panel; the settings panel also carries Version (CI-stamped) and License metadata.

### Changed

- Split the background `PanelColor` variable into `PanelColorRGB` (color) and `PanelOpacity` (alpha) so
  opacity can be changed independently of the color.
- The verse font style is now driven by a `QuoteStyle` variable (was a hardcoded `StringStyle=Italic`);
  the default font style is now Regular.
- The verse no longer changes when the quote window is clicked; use the next-verse control instead.
- Appearance changes (font, colors, size, opacity, width, height, reference label, icon visibility) apply
  to the running skin without refetching a new verse; the settings panel never refreshes itself. Rotation
  changes (auto-rotation on/off, duration) and Reset refresh the main skin, which fetches a new verse.
- The open (main panel) and close (settings panel) controls are drawn as vector shapes instead of font
  glyphs, so they always render correctly regardless of file encoding.

### Fixed

- Toggling "Change verse automatically" (or changing the rotation duration) no longer replaces the
  displayed verse. Rotation is now decoupled from the download: a new `[MeasureRotateTick]` timer fetches
  the next verse every `RotateEvery` seconds while `AutoChange` is on, and the settings panel applies both
  via `!SetVariable` (read dynamically) instead of `!Refresh`, so the current verse stays put. Removed the
  now-unused `EffectiveRate` variable.
- The next-verse control and the rotation timer now fetch reliably. `[MeasureQuran]` keeps updating with a
  very large `UpdateRate` (`DownloadOnDemandRate`) so it never auto-downloads, and both triggers pair
  `!CommandMeasure ... "Update"` with `!UpdateMeasure` so the download starts immediately (`UpdateDivider=-1`
  would have stopped the measure updating, leaving forced updates with nothing to process).
- Verses now load on machines with proxy auto-detection (WPAD) enabled. `[MeasureQuran]` sets
  `ProxyServer=/none` to force a direct connection; WebParser otherwise uses the system/IE proxy config,
  which could hang the download indefinitely (no `FinishAction`, no error) and leave the skin stuck on
  "Loading verse...".
- The panel no longer gets stuck on "Loading verse..." when the verse download fails. `[MeasureQuran]`
  now has an `OnDownloadErrorAction` that falls back to an offline verse, alongside the existing connect
  and regex error handlers (a failed HTTPS download, e.g. through a proxy or antivirus, previously left no
  handler to run).
- The settings icon no longer overlaps the verse text; the verse now starts below the icon.

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
