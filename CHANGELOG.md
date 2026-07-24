# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-07-25

### Added

- Al-Quran Quote Rainmeter skin (GitHub issue #1): a minimal, semi-transparent desktop widget showing a
  random Quran verse (Saheeh International English translation) with its reference.
- Verses are fetched live from the quran.com API v4 `verses/random` endpoint over a direct connection
  (`ProxyServer=/none`), so proxy auto-detection (WPAD) cannot hang the download. When the network or the
  request fails, an offline verse from the bundled `quotes.txt` is shown instead.
- Automatic rotation on a timer (default every 30 minutes), decoupled from the download so toggling
  rotation or changing the duration never refetches the current verse. A next-verse control by the
  reference fetches the next verse on demand.
- Settings panel (opened from an icon on the skin) to change appearance and behavior without editing
  files; changes save to `Variables.inc` and apply immediately. It is organized into three tabs
  (Text / Panel / Verse), each laid out in two columns:
  - Font family (a curated clickable list plus a type-any-font input), a size slider, and style buttons
    (Bold / Regular / Italic).
  - Font color and background color via R/G/B(/A) sliders with a live preview swatch; colors and opacity
    can also be typed directly.
  - Background opacity and border opacity sliders.
  - Panel width and height: automatic, or a fixed pixel value.
  - Automatic rotation on/off and the change duration (seconds between verses).
  - Editable reference label (default "Al Quran"), with show/hide toggles for the label and the verse
    number (applied to both fetched and custom verses).
  - Custom verse: show your own text with an optional manual sura and verse number (both nullable) instead
    of a fetched verse; while it is on, rotation pauses and the next-verse control is hidden so the custom
    verse is never overwritten.
  - Show or hide the settings icon on the skin, and a Reset to defaults.
- Appearance and reference changes apply to the running skin live (via `!SetVariable`) without refetching a
  verse; only Reset refreshes. The reference line is composed in Lua so a hidden part leaves no gap and a
  lone label stays centered.
- Icons (settings, next-verse, close) are drawn as vector shapes so they render regardless of file
  encoding. The settings panel's look lives in its own `Settings/@Resources/SettingsTheme.inc`, kept
  separate from the skin's variables so editing the skin never restyles the panel.
- All appearance and timing settings centralized in `@Resources/Variables.inc`.
- `.rmskin` installer built and attached to the GitHub Release automatically via GitHub Actions
  (`.github/workflows/rmskin.yml`). `RMSKIN.ini` is the single source of truth for the version.
- Author website URL (https://shibbirweb.github.io) in the `[Metadata] Information` of both configs.
- Developer guide in `docs/DEVELOPER.md`.
