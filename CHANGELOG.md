# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Add notes for the next release here under the headings Added, Changed, Fixed, or Removed.

## [1.0.0] - 2026-07-23

### Added

- Initial release of the Al-Quran Quote Rainmeter skin (GitHub issue #1).
- Shows a random Quran verse (Saheeh International English translation) with its reference on a
  minimal, semi-transparent panel.
- Fetches verses live from the quran.com API v4 `verses/random` endpoint.
- Offline fallback: shows a random verse from the bundled `quotes.txt` when there is no connection.
- Left-click for the next verse; automatic rotation on a timer (default every 30 minutes).
- All appearance and timing settings centralized in `@Resources/Variables.inc`.
