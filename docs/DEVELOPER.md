# Developer Guide

How the Al-Quran Quote skin is built, how to work on it locally, and how to ship a release. For the
short rules-of-the-road, see [CLAUDE.md](../CLAUDE.md); this guide is the longer explanation.

## What it is

A minimal Rainmeter skin (a Windows desktop widget) that shows a random Quran verse in English
(Saheeh International translation) with its reference, for example `Quran 2:152`. It fetches verses
live from the quran.com API, rotates on a timer, changes on click, and falls back to a bundled list
when offline. It matches the mockup in [docs/mockup.png](mockup.png).

## Repository layout

```
Skins/AlQuranQuote/              The skin (this layout is what the rmskin packager expects)
  AlQuranQuote.ini               Structure only: [Rainmeter], [Metadata], measures, meters
  @Resources/
    Variables.inc                All tunables (colors, fonts, sizes, RotateEvery)
    Scripts/RandomAyah.lua        Entry points: Initialize, Update, Online, Offline
    Scripts/Verse.lua             applyVerse(quote, reference): set display vars + repaint
    Scripts/QuoteFile.lua         readLines(path), parseLine(line): offline file I/O + parsing
    quotes.txt                   Offline verses, one "English | Quran X:Y" per line
RMSKIN.ini                       Packaging metadata; also the single source of truth for the version
.github/workflows/rmskin.yml     CI: builds the .rmskin and attaches it to the release on a v* tag
docs/                            This guide and the mockup image
CHANGELOG.md  README.md  CLAUDE.md  LICENSE
```

## How it works

### Data source

```
https://api.quran.com/api/v4/verses/random?language=en&translations=20
```

- `verses/random` returns one server-picked random verse, so there is no client-side ayah math.
- `translations=20` is Saheeh International (English). Resource ids can be listed from
  `https://api.quran.com/api/v4/resources/translations`.
- The verse object always carries `verse_key` (for example `2:152`), which becomes the reference.

### Fetch and parse (WebParser)

`[MeasureQuran]` is a `Plugin=WebParser` measure that downloads the URL above and applies this regex
(dotall, ungreedy):

```
(?siU)"verse_key":"(.*)".*"text":"(.*)"
```

Two child measures read the captured groups by `StringIndex`:

- `MeasureKey` (index 1) = `verse_key`
- `MeasureEnglish` (index 2) = the translation text, with `RegExpSubstitute` stripping any `<...>`
  footnote markup.

### Display (Lua bridge)

WebParser downloads on a background thread, so the skin uses callbacks rather than reading values
inline:

1. On success, `FinishAction` calls `Online()` (in `RandomAyah.lua`), which reads the two child
   measures and calls `applyVerse(english, "Quran " .. verseKey)`.
2. On failure, `OnConnectErrorAction` / `OnRegExpErrorAction` call `Offline()`, which picks a random
   line from `quotes.txt` and calls `applyVerse(...)`.
3. `applyVerse()` (in `Verse.lua`) sets the `#QuoteText#` and `#RefText#` variables and repaints.
4. The `[MeterQuote]` and `[MeterReference]` string meters display those variables.

`RandomAyah.lua` loads its two helper files in `Initialize()` with
`dofile(SKIN:GetVariable('@') .. 'Scripts\\...')`. Use `GetVariable('@')`, not a `#@#` string
literal: Rainmeter does not expand `#@#` inside a Lua string.

### Rotation and click

- Rotation: WebParser `UpdateRate=#RotateEvery#` re-downloads on a timer (a new random verse each
  time). `RotateEvery` is in skin update cycles; with `Update=1000` (1 second) the default 1800 is
  30 minutes.
- Click: the panel's `LeftMouseUpAction=[!CommandMeasure MeasureQuran "Update"]` forces an immediate
  re-download.

## Local development (Windows)

Rainmeter is Windows only; you cannot render the skin on macOS or Linux.

1. Install Rainmeter from https://www.rainmeter.net.
2. Put the skin where Rainmeter can see it. Either copy `Skins/AlQuranQuote` into
   `Documents\Rainmeter\Skins\`, or point Rainmeter's skins folder at this repo's `Skins` directory.
3. Rainmeter -> Manage -> Refresh all, then load `AlQuranQuote\AlQuranQuote.ini`.
4. After editing any file, right-click the skin -> Refresh to reload it.

### Testing checklist

- A verse and a `Quran X:Y` reference render (not stuck on "Loading verse...").
- The verse changes on left-click and on the rotation timer.
- With networking disabled, an offline verse from `quotes.txt` still appears.
- Rainmeter -> About -> Log has no errors for the skin.

### Debugging

- Open Rainmeter -> About -> Log and enable all levels (Error, Warning, Notice, Debug).
- To trace Lua, add temporary log lines: `SKIN:Bang('!Log', 'AlQuranQuote: <message>')`. Remove them
  before committing.
- To inspect the raw download and regex matches, temporarily add `Debug=2` to `[MeasureQuran]`.

### Known gotcha

Do NOT put `DynamicVariables=1` on the `[MeasureQuran]` WebParser parent. Because the download runs on
a background thread, `DynamicVariables=1` makes the parent re-read its URL every update and the
download never settles, so `FinishAction` never fires and the skin stays on "Loading verse..." with no
error in the log. The text meters and the panel Shape do use `DynamicVariables=1`, which is correct.

## Theming and configuration

All tunables live in [Variables.inc](../Skins/AlQuranQuote/@Resources/Variables.inc): `RotateEvery`,
panel size (`PanelWidth`, `Pad`, `Radius`), fonts (`QuoteFont`, `RefFont`, `QuoteSize`, `RefSize`),
and colors (`QuoteColor`, `RefColor`, `PanelColor`, `PanelBorder`, all `R,G,B,A`). Edit and refresh.

## Add an offline verse

Append a line to [quotes.txt](../Skins/AlQuranQuote/@Resources/quotes.txt):

```
English translation text | Quran X:Y
```

The part before the `|` is the quote, the part after is the reference. Avoid a literal `|` inside the
quote text.

## Coding conventions

- Small, single-purpose functions; each reads top to bottom and does one thing.
- Descriptive names only, no abbreviations (for example `verseKey`, not `k`).
- Human-readable syntax: explicit `if` blocks over one-line tricks; no `value or default` fallbacks;
  no nested ternaries.
- Keep structure and configuration separate: `AlQuranQuote.ini` holds structure, `Variables.inc`
  holds tunables (pulled in with `@IncludeVariables`).
- No bundled font or image binaries; use a system font and a Shape panel.
- No em dash (Unicode U+2014) anywhere in code, comments, docs, or commit messages.

## Versioning and releases

`RMSKIN.ini` `[rmskin] Version` is the single source of truth for the version. Do not hand-edit the
skin's `[Metadata] Version`; CI stamps it from `RMSKIN.ini` at build time.

To cut a release:

1. Bump `Version` in [RMSKIN.ini](../RMSKIN.ini) and add a matching section to
   [CHANGELOG.md](../CHANGELOG.md).
2. Commit and push that change to `master`.
3. Create a tag equal to the version (any one of these):
   - Local: `git tag v1.2.0 && git push origin v1.2.0`
   - GitHub UI: Releases -> Draft a new release -> create tag `v1.2.0` on publish
   - GitHub CLI: `gh release create v1.2.0`
4. The [workflow](../.github/workflows/rmskin.yml) verifies the tag matches `RMSKIN.ini`, builds the
   `.rmskin` with [2bndy5/rmskin-action](https://github.com/2bndy5/rmskin-action), and attaches it to
   the release.

To test a build without releasing, run the workflow manually (Actions -> Package rmskin -> Run
workflow). It produces a `0.0.0-dev` `.rmskin` as a downloadable artifact and does not create a
release. The built `.rmskin` is git-ignored on purpose; distribute it through Releases, not the repo.
