# CLAUDE.md

Guidance for anyone (human or AI) working on this repository.

## About the project

A minimal Rainmeter skin (a Windows desktop widget) that shows a random verse from the Holy Quran
(Sahih International English translation) with its reference, per GitHub issue #1. It is intentionally
small: an English quote plus a `Quran X:Y` reference on a semi-transparent panel. Click for the next
verse; it also rotates on a timer.

## Architecture

```
Skins/AlQuranQuote/           Skin folder (this layout is what the rmskin packager expects).
  AlQuranQuote.ini            Skin structure only: [Rainmeter], [Metadata], measures, meters.
  @Resources/
    Variables.inc             All tunables (colors, fonts, sizes, RotateEvery). Themed here.
    Scripts/RandomAyah.lua     Entry points: Initialize, Update, Online, Offline.
    Scripts/Verse.lua          applyVerse(quote, ref): sets display vars, repaints.
    Scripts/QuoteFile.lua      readLines(path), parseLine(line): offline file I/O and parsing.
    quotes.txt                Offline verses, one "English | Quran X:Y" per line.
RMSKIN.ini                    Packaging metadata read by the rmskin packager.
.github/workflows/rmskin.yml  CI: builds the .rmskin and attaches it to the release on a v* tag.
```

Paths inside `RMSKIN.ini` (`LoadName`, `VariableFiles`) are relative to `Skins/`, so they stay
`AlQuranQuote\...` even though the folder now lives under `Skins/`.

Data flow:

1. `[MeasureQuran]` (WebParser) fetches
   `https://api.quran.com/api/v4/verses/random?language=en&translations=20`
   (translation resource 20 = Saheeh International). `verses/random` returns a new verse on every real
   download, so no cache-buster is needed. `UpdateRate=#RotateEvery#` re-downloads on a timer
   (rotation); clicking the panel runs `[!CommandMeasure MeasureQuran "Update"]` to fetch immediately.
2. Child measures extract fields via `StringIndex` from the regex
   `(?siU)"verse_key":"(.*)".*"text":"(.*)"`: `MeasureKey` (1) = verse_key, `MeasureEnglish` (2) =
   translation (HTML tags stripped via `RegExpSubstitute`).
3. On success `FinishAction` calls `Online()`, which reads the child measures and calls
   `applyVerse(english, "Quran " .. key)`. On error, `On*ErrorAction` calls `Offline()`, which shows a
   random line from `quotes.txt`.
4. Meters display the `#QuoteText#` and `#RefText#` variables set by `applyVerse`.

Gotcha: do NOT put `DynamicVariables=1` on the `[MeasureQuran]` WebParser parent. WebParser downloads
on a background thread; with `DynamicVariables=1` it re-reads the URL every update and the download
never settles, so `FinishAction` never fires and the skin stays on "Loading verse...".

## Rules and conventions

- Keep it minimal: English translation plus reference only, matching the issue #1 mockup. No Arabic.
- Small, single-purpose functions; each reads top-to-bottom and does one thing.
- Descriptive names only: no short or abbreviated variable names. A name must state its purpose so a
  reader understands the code without guessing (for example `verseKey`, not `k`; `englishTranslation`,
  not `t`). This applies to variables, function parameters, and config variables.
- Human-readable syntax over clever shorthand: prefer an explicit `if` block to terse one-liners or
  short-circuit tricks (for example do not lean on `value or default` to assign a fallback; write the
  `if` check out).
- No nested ternary operators. Use plain `if` / `elseif` / `else` blocks instead.
- Split config from structure: `AlQuranQuote.ini` holds structure only; every tunable lives in
  `Variables.inc` and is pulled in with `@IncludeVariables`.
- No bundled font or image binaries: use a system font and a Shape panel.
- Never hardcode magic numbers; name them in `Variables.inc` or as Lua locals.
- Test on Windows with Rainmeter before shipping; package a release as a `.rmskin`.
- Version single source of truth: `RMSKIN.ini` `[rmskin] Version`. Edit the version only there. CI
  stamps that value into the skin's `[Metadata] Version` at build time (do not hand-edit `[Metadata]
  Version`), and on a `v*` tag CI fails the release if the tag does not match `RMSKIN.ini`. The git
  tag and the `CHANGELOG.md` heading must equal the `RMSKIN.ini` version.
- Update `CHANGELOG.md` on every release: record changes under the `[Unreleased]` section as you work,
  then move them into a new dated section headed with the `RMSKIN.ini` version at release time. Follow
  the Keep a Changelog format and Semantic Versioning.
- No em dash (the long dash, Unicode U+2014) anywhere in text, content, code comments, docs, or commit
  messages. Use a regular hyphen, a comma, or reword.

## Git

- Author name: `MD. Shibbir Ahmed`. Email: `shibbirweb@gmail.com`.
  Set locally: `git config user.name "MD. Shibbir Ahmed"` and
  `git config user.email shibbirweb@gmail.com`.
- Never add Claude as a co-author: no `Co-Authored-By: Claude ...` line and no
  "Generated with Claude Code" footer in commits or PRs.

## Run and test

1. Copy `AlQuranQuote` into `Documents\Rainmeter\Skins\`.
2. Rainmeter -> Manage -> Refresh all, then load `AlQuranQuote\AlQuranQuote.ini`.
3. Verify: a verse and `Quran X:Y` render; the verse changes on click and on the timer; with the
   network off, an offline verse shows. Check About -> Log for errors.

## Add an offline verse

Append a line to `@Resources/quotes.txt`: `English translation text | Quran X:Y`.
