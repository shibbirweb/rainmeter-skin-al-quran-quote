# Developer Guide

How the Al-Quran Quote skin is built, how to work on it locally, and how to ship a release. For the
short rules-of-the-road, see [CLAUDE.md](../CLAUDE.md); this guide is the longer explanation.

## What it is

A minimal Rainmeter skin (a Windows desktop widget) that shows a Quran verse with its reference, for
example `Al Quran 2:152`, on a semi-transparent panel. It:

- Fetches a random verse live from the quran.com API, or works fully offline from a bundled list.
- Persists the displayed verse, so a restart shows the same verse instead of refetching.
- Rotates to a new verse on a timer (default every 30 minutes), decoupled from the download.
- Has a settings panel (three tabs) for fonts, colors, size, shadow, rotation, language, and more, with
  no file editing.
- Can show your own custom text instead of a fetched verse.
- Supports many online languages (including the original Arabic).
- Ships a pool of up to 8 independent quote windows, one per screen.

It matches the mockup in [docs/mockup.png](mockup.png).

## Repository layout

```
Skins/AlQuranQuote/              The skin (this layout is what the rmskin packager expects)
  AlQuranQuote.ini               Window 1 (base): [Rainmeter], [Metadata], includes, @Include Quote.inc
  Windows/W2..W8/                Pooled clone windows (activated on demand)
    Wn/Wn.ini                    Tiny config that @Includes the shared Quote.inc
    Wn/@Resources/               That window's own Variables.inc (styling) + LastVerse.inc (its verse)
  Settings/
    Settings.ini                 Settings panel (a separate child config; retargets to the opening window)
    @Resources/SettingsTheme.inc The panel's OWN look, layout, font/language lists, and working state
  @Resources/
    Quote.inc                    SHARED render: measures + meters, @Include'd by the base and every clone
    Variables.inc                Base window tunables + global WindowCount/MaxWindows (ASCII)
    LastVerse.inc                Base window's persisted verse (UTF-16)
    UserContent.inc              SHARED ReferenceLabel + CustomText (UTF-16)
    Target.inc                   Which window the settings panel is editing (TargetConfig)
    quotes.txt                   SHARED offline verses, one "English | Quran X:Y" per line
    Scripts/RandomAyah.lua       Entry points: Initialize, Update, Online, Offline, nextVerse (UTF-16)
    Scripts/Verse.lua            applyVerse(quote, ref): set display vars, persist, repaint
    Scripts/QuoteFile.lua        readLines(path), parseLine(line): offline file I/O + parsing
    Scripts/Settings.lua         Backs the settings panel: seed from / apply to the target window (UTF-16)
RMSKIN.ini                       Packaging metadata; also the single source of truth for the version
.github/workflows/rmskin.yml     CI: builds the .rmskin and attaches it to the release on a v* tag
.github/workflows/publish-wiki.yml  CI: mirrors wiki/ into the GitHub Wiki on change
wiki/                            Source of truth for the GitHub Wiki (user documentation)
docs/                            This guide and the mockup image
CHANGELOG.md  README.md  CLAUDE.md  LICENSE
```

## Windows and shared code

The skin ships a pool of up to 8 quote windows. Window 1 is the base `AlQuranQuote.ini`; windows 2 to 8
are pre-shipped clone configs at `Windows/Wn/Wn.ini`.

- **Code is shared:** the measures and meters live once in [Quote.inc](../Skins/AlQuranQuote/@Resources/Quote.inc),
  which the base and every clone `@Include`. The shared scripts and `quotes.txt` live in the base
  `@Resources`, reached with the built-in `#SKINSPATH#AlQuranQuote\@Resources\`.
- **State is per window:** each window persists its own verse to its OWN `@Resources\LastVerse.inc` (via
  `#CURRENTPATH#`), and has its own `Variables.inc` (independent styling). `UserContent.inc` (reference
  label, custom text) is shared from the base.
- A subfolder config's `#@#` resolves to the ROOT `@Resources`, so clones use `#CURRENTPATH#` for their
  own state, never `#@#`.

The settings panel's "Quote windows" spinner activates or deactivates `Windows\W2..W8` via
`!ActivateConfig` / `!DeactivateConfig`; Rainmeter reloads active configs on restart, so the count sticks.
`WindowCount` is global and always persists to the base `Variables.inc`.

> **Gotcha:** do NOT reintroduce a custom path variable like `SharedRes=#SKINSPATH#...` for `ScriptFile`.
> Rainmeter does not re-expand a built-in nested inside a custom variable when resolving `ScriptFile`, so
> the script path comes out invalid ("Script: File not valid"). Use the built-in directly.

## How it works

### Data source

```
https://api.quran.com/api/v4/verses/random?language=en&translations=20
```

- `verses/random` returns one server-picked random verse on every real download, so there is no
  client-side ayah math and no cache-buster is needed.
- `translations=20` is Saheeh International (English). Resource ids can be listed from
  `https://api.quran.com/api/v4/resources/translations`.
- The verse object always carries `verse_key` (for example `2:152`), which becomes the reference key.
- The URL and the regex text field come from the `ApiUrl` / `ApiTextField` / `ApiTextQuant` variables, so
  the language is configurable. Arabic is special: it has no translation resource, so it uses a
  `fields=text_uthmani` URL and a lazy quantifier. See [Languages and translations](#languages-and-translations).

### Fetch and parse (WebParser)

`[MeasureQuran]` is a `Plugin=WebParser` measure that downloads the URL and applies:

```
(?siU)"verse_key":"(.*)".*"#ApiTextField#":"#ApiTextQuant#"
```

Two child measures read the captured groups by `StringIndex`:

- `MeasureKey` (index 1) = `verse_key`.
- `MeasureEnglish` (index 2) = the translation text, with `RegExpSubstitute` stripping `<sup>` footnote
  blocks whole and then any remaining `<...>` markup.

The text group is **greedy** (`(.*?)` under the `(?U)` flag) so it runs to the real closing quote; a lazy
group would stop at the first escaped quote inside verses that contain quotation marks (for example 23:47)
and truncate them. `Online()` then converts the API's `\"` and `\/` escapes back to `"` and `/`.

On success `FinishAction` calls `Online()`; on error `OnConnectErrorAction` / `OnDownloadErrorAction` /
`OnRegExpErrorAction` call `Offline()`.

### Display (Lua bridge)

WebParser downloads on a background thread, so the skin uses callbacks rather than reading values inline.
The Lua is split across small files, all dofile'd by [RandomAyah.lua](../Skins/AlQuranQuote/@Resources/Scripts/RandomAyah.lua):

1. `Online()` reads the child measures, unescapes the text, and calls `applyVerse(english, verseKey, true)`.
2. `Offline()` shows the NEXT line of `quotes.txt` (a module-level index advances and wraps, so offline
   verses cycle sequentially), split on the first `|` into `quote | reference`, with the reference shown
   verbatim (no label) via `applyVerse(quote, reference, false)`.
3. `applyVerse(quoteText, verseKey, useLabel)` (in [Verse.lua](../Skins/AlQuranQuote/@Resources/Scripts/Verse.lua))
   sets `#QuoteText#`, `#VerseKey#`, `#RefUseLabel#`, composes `#RefText#` (in `composeReferenceText`) from
   the label, key, and the two show toggles, persists everything, and repaints.
4. `[MeterQuote]` shows `#QuoteText#`; `[MeterReference]` shows `#RefText#`. Composing the reference in Lua
   (not in the meter) lets either part be hidden and drops the trailing space so a lone label stays centered.

`useLabel` is true for online and custom verses (the label may prefix the key) and false for offline
verses (reference shown verbatim). `refreshReference` reads `#RefUseLabel#` so a later toggle change
recomposes the same way.

### Verse source selection

The next-verse control and the rotation tick both call `nextVerse()`, which picks the source in order:

1. The **custom verse** if `#CustomVerseEnabled#` is 1 (routes to `applyCustomVerse()`; no fetch).
2. Else an **online download** if `#OnlineFetchEnabled#` is 1 (`CommandMeasure MeasureQuran "Update"` plus
   `!UpdateMeasure`).
3. Else a new **offline verse** from `quotes.txt`.

When online fetching is off, `Online()` ignores the one background download that still happens on load
(it returns early), and `Initialize` shows an offline verse immediately.

### Custom verse

When `#CustomVerseEnabled#` is 1 the skin shows `#CustomText#` with the manual `#SuraNumber#:#VerseNumberManual#`
as the reference key, instead of fetching. Both numbers are nullable: if either is empty the key is empty
and the reference shows just the label (centered). Rotation is gated off and the next-verse control is
hidden, so a stray download can never overwrite the custom verse. Toggling the mode off calls `nextVerse()`
to show a fresh verse.

### Rotation

Rotation is decoupled from the download, so toggling rotation or changing the duration never refetches the
displayed verse. `[MeasureRotateTick]` (a `Calc`, `DynamicVariables=1`) counts one per second (the skin's
`Update=1000`) and wraps to 0 every `RotateEvery` seconds via `(MeasureRotateTick + 1) % #RotateEvery#`.
When it hits 0 and `#AutoChange#` is 1 (and no custom verse), it fires `nextVerse()`.

The WebParser must keep updating for on-demand fetches to work, so it uses `UpdateRate=#DownloadOnDemandRate#`
(a very large value), NOT `UpdateDivider=-1`. `CommandMeasure "Update"` only resets the WebParser's internal
counter; the actual download runs on the measure's next update. With `UpdateDivider=-1` the measure never
updates again, so `Update` silently downloads nothing. See [Known gotchas](#known-gotchas).

### Verse persistence

The displayed verse is saved so a restart shows the SAME verse. `applyVerse` writes
`QuoteText`/`VerseKey`/`RefText`/`RefUseLabel` and `VersePersisted=1` to `@Resources\LastVerse.inc` (a
UTF-16 file, so Unicode verse text survives `WritePrivateProfileString`), which the base skin
`@IncludeVariables2`s after `Variables.inc` so its saved values win on load. To stop the restored verse
being overwritten, `[MeasureQuran]` is `Disabled=1` (no download on load); `nextVerse()` `!EnableMeasures`
it before fetching. On load `Initialize` keeps the restored verse when `VersePersisted=1` and only fetches
on first run. Reset writes `VersePersisted=0` so a fresh verse shows after the refresh.

### Settings panel

The settings icon on a quote window toggles `AlQuranQuote\Settings` (`Settings.ini`) via `!ToggleConfig`.
It lives in the `Settings/` subfolder on purpose: a subfolder is a separate Rainmeter config, so it runs
alongside the main skin. A sibling `.ini` in the same folder would be a variant of the same config and
would replace the main panel instead.

- The panel reads its own [SettingsTheme.inc](../Skins/AlQuranQuote/Settings/@Resources/SettingsTheme.inc)
  (its look, layout, curated font and language lists, and working state) and the target window's
  `Variables.inc` (only to seed the controls). Keeping the panel's look in its own file is deliberate:
  editing the skin never restyles the panel.
- It is split into three tabs (Text / Panel / Verse) so it stays short. Each content meter is in a
  `Tab1`/`Tab2`/`Tab3` group; `setTab(n)` hides the other two. The Reset button and the footer "report an
  issue" link have no group, so they show on every tab.
- **Targeting:** the one panel edits whichever window opened it. Each window's gear writes its config name
  to `Target.inc` and reloads the panel, whose [Settings.lua](../Skins/AlQuranQuote/@Resources/Scripts/Settings.lua)
  reads `TargetConfig`, derives that window's `@Resources` from it plus `#SKINSPATH#`, seeds the controls
  by io-parsing that window's `Variables.inc`, and applies back to it.
- **Apply path:** on any change `Settings.lua` writes the value with `!WriteKeyValue`, then applies it live.
  Appearance changes use `!SetVariable ... "AlQuranQuote"` (plus `!UpdateMeter`/`!Redraw`) so the verse does
  NOT refetch. Reference and custom changes call `refreshDisplay()` to recompose without refetching. Only
  Reset uses `!Refresh`.

## Languages and translations

The fetch URL and regex text field come from `ApiUrl` / `ApiTextField` / `ApiTextQuant` (resolved at load;
default English, translation 20).

- Most languages are a `translations=<id>` URL and extract the greedy `"text":"(.*?)"` (greedy under
  `(?U)`, for escaped quotes).
- Arabic has no translation resource, so it uses a `fields=text_uthmani` URL and extracts
  `"text_uthmani":"(.*)"` (LAZY under `(?U)`: the Arabic text has no inner quotes but numeric fields follow
  it, so greedy would over-run).

The settings Language control is a curated click-to-open list (defined in `SettingsTheme.inc`) plus a
"type a translation id" input for any of the ~126 quran.com translations. `Settings.lua`'s `applyLanguage`
persists the url/field/quant/name and rewrites the live measure with `!SetOption MeasureQuran URL ...` and
`!SetOption ... RegExp ...` (the WebParser must not carry `DynamicVariables`, so `!SetVariable` alone would
not update the already-resolved options). Non-Latin scripts render only if the `QuoteFont` has their glyphs.

## Encoding notes

Encoding matters here, and getting it wrong shows up as `?` or mojibake:

- `RandomAyah.lua` and `Settings.lua` are saved as **UTF-16 LE with a BOM**. Rainmeter only treats a Lua
  script as Unicode when its file starts with the UTF-16 LE BOM; otherwise every string crossing the
  Rainmeter/Lua boundary is converted with the ANSI codepage, turning characters like the `a`-macron in
  "Allah" into `?`. Because `MeasureRandom` owns `RandomAyah.lua`, its Unicode flag governs the whole verse
  pipeline (including `applyVerse` in the dofile'd `Verse.lua`).
- The helper files `Verse.lua` / `QuoteFile.lua` and `quotes.txt` stay UTF-8 (read as UTF-8 bytes and
  marshaled through `MeasureRandom`'s Unicode scope).
- `LastVerse.inc` and `UserContent.inc` are **UTF-16** because `!WriteKeyValue` (WritePrivateProfileString)
  only persists Unicode when the target file has a UTF-16 BOM. The user-typed `ReferenceLabel` and
  `CustomText` live in `UserContent.inc` for this reason; `Variables.inc` stays **ASCII** so the rmskin
  `VariableFiles` installer still parses it.
- Keep `.ini` / `.inc` files ASCII. Icons are drawn as vector Shapes (not font glyphs) to avoid mojibake
  when a file with non-ASCII glyphs is read as ANSI. If a file ever needs non-ASCII, save it as UTF-8 with
  a BOM (Rainmeter reads UTF-8 without a BOM as ANSI).

Editing a UTF-16 file with plain text tools is awkward: convert to UTF-8, edit, then convert back to
UTF-16 LE with BOM, or edit it via a script.

## Local development (Windows)

Rainmeter is Windows only; you cannot render the skin on macOS or Linux.

1. Install Rainmeter from https://www.rainmeter.net.
2. Put the skin where Rainmeter can see it. Either copy `Skins/AlQuranQuote` into
   `Documents\Rainmeter\Skins\`, or point Rainmeter's skins folder at this repo's `Skins` directory.
3. Rainmeter -> Manage -> Refresh all, then load `AlQuranQuote\AlQuranQuote.ini`.
4. After editing any file, right-click the skin -> Refresh to reload it.

### Testing checklist

- A verse and a `Quran X:Y` reference render (not stuck on "Loading verse...").
- The verse changes with the next-verse control and on the rotation timer.
- With online fetch on and networking disabled, an offline verse from `quotes.txt` still appears.
- Restarting Rainmeter restores the same verse (does not refetch).
- The settings panel opens, its controls apply live without refetching, and a second window can be styled
  independently.
- Rainmeter -> About -> Log has no errors for the skin.

### Debugging

- Open Rainmeter -> About -> Log and enable all levels (Error, Warning, Notice, Debug).
- To trace Lua, add temporary log lines: `SKIN:Bang('!Log', 'AlQuranQuote: <message>')`. Remove them
  before committing.
- To inspect the raw download and regex matches, temporarily add `Debug=2` to `[MeasureQuran]`.

## Known gotchas

- **No `DynamicVariables=1` on `[MeasureQuran]`.** The download runs on a background thread; with
  `DynamicVariables=1` the parent re-reads its URL every update and the download never settles, so
  `FinishAction` never fires and the skin stays on "Loading verse..." with no error. The text meters and
  the panel Shape do use `DynamicVariables=1`, which is correct.
- **`ProxyServer=/none` (with the leading slash).** WebParser defaults to the system/IE proxy; with proxy
  auto-detection (WPAD) the download can hang forever with no `Finished` and no error action. `/none` maps
  to a direct connection; any other string (including `None` without the slash) is treated as a literal
  proxy hostname and still hangs. Do NOT remove it or drop the slash.
- **`UpdateRate=#DownloadOnDemandRate#`, not `UpdateDivider=-1` or `UpdateRate=0`.** A large non-zero rate
  keeps the WebParser counter climbing so it never auto-downloads on its own timer, while
  `Command "Update"` (paired with `!UpdateMeasure`) still fetches on demand. `UpdateDivider=-1` makes
  `Update` download nothing; `UpdateRate=0` refetches every second and thrashes.
- **Clones use `#CURRENTPATH#`, never `#@#`.** In a subfolder config `#@#` resolves to the ROOT
  `@Resources`, so clones must use their own folder for state and `@IncludeVariables`.
- **Built-ins in `ScriptFile`.** Use the built-in path directly; a custom variable wrapping a built-in is
  not re-expanded when resolving `ScriptFile`.

## Theming and configuration

All tunables live in [Variables.inc](../Skins/AlQuranQuote/@Resources/Variables.inc) and are almost all
editable from the settings panel. Highlights:

- **Content / behavior:** `ShowReferenceLabel`, `ShowVerseNumber`, `CustomVerseEnabled`, `SuraNumber`,
  `VerseNumberManual`, `RotateEvery`, `AutoChange`, `OnlineFetchEnabled`.
- **Language:** `ApiUrl`, `ApiTextField`, `ApiTextQuant`, `ApiLanguage`, `ApiTranslation`, `ApiLanguageName`.
- **Layout:** `PanelWidth`, `DefaultPanelWidth`, `WidthAuto`, `FixedWidth`, `HeightAuto`, `FixedHeight`,
  `Pad`, `Radius`, `IconGap`.
- **Theme:** `QuoteFont`, `RefFont`, `QuoteSize`, `RefSize`, `QuoteStyle`, `RefStyle`, `QuoteColor`,
  `RefColor`; the quote drop shadow `QuoteShadowEnabled`, `QuoteShadowColor`, `QuoteShadowOffsetX/Y`; and
  the background/border `PanelColorRGB`, `PanelOpacity`, `PanelBorderRGB`, `PanelBorderOpacity`.
- **Windows:** `WindowCount`, `MaxWindows`, `WindowNumber`, `Editing`.
- **Bounds:** named `Min*`/`Max*` limits the settings panel clamps numeric input to.

The persisted verse (`QuoteText`, `VerseKey`, `RefText`, `RefUseLabel`) lives in `LastVerse.inc`, and the
user-typed `ReferenceLabel` / `CustomText` live in `UserContent.inc` (both UTF-16). See
[Encoding notes](#encoding-notes).

## Add an offline verse

Append a line to [quotes.txt](../Skins/AlQuranQuote/@Resources/quotes.txt):

```
English translation text | Quran X:Y
```

The line is split on the first `|`: the left side is the quote, the right side is the reference, shown
verbatim (not parsed, so it can be any text). `Offline()` re-reads the file each call, so edits appear on
the next verse change with no refresh. The settings Verse tab has an "open offline verses file" control.

## Coding conventions

- Small, single-purpose functions; each reads top to bottom and does one thing.
- Descriptive names only, no abbreviations (for example `verseKey`, not `k`).
- Human-readable syntax: explicit `if` blocks over one-line tricks; no `value or default` fallbacks;
  no nested ternaries.
- Keep structure and configuration separate: `AlQuranQuote.ini` holds structure, `Variables.inc`
  holds tunables (pulled in with `@IncludeVariables`).
- No bundled font or image binaries; use a system font and a Shape panel.
- No em dash (Unicode U+2014) anywhere in code, comments, docs, or commit messages.

## Documentation

- **User docs** live in [wiki/](../wiki), the source of truth for the project's GitHub Wiki. Edit the
  Markdown there and push; the [publish-wiki workflow](../.github/workflows/publish-wiki.yml) mirrors the
  folder into the wiki on every change to `wiki/`. Do not edit the wiki through GitHub's web editor, it
  would be overwritten on the next publish. A repo's wiki must be initialized once (create any first page
  in the Wiki tab) before the workflow can publish.
- **This guide** and the mockup image live in `docs/`. The short rules are in [CLAUDE.md](../CLAUDE.md).

## Versioning and releases

`RMSKIN.ini` `[rmskin] Version` is the single source of truth for the version. Do not hand-edit any skin's
`[Metadata] Version`; CI stamps it into every `.ini` under the skin tree (the base, the settings panel, and
each clone window) from `RMSKIN.ini` at build time.

To cut a release:

1. Bump `Version` in [RMSKIN.ini](../RMSKIN.ini) and move the `CHANGELOG.md` `[Unreleased]` entries into a
   new dated section headed with that version.
2. Commit and push that change to `master`.
3. Create a tag equal to the version (any one of these):
   - Local: `git tag v1.2.0 && git push origin v1.2.0`
   - GitHub UI: Releases -> Draft a new release -> create tag `v1.2.0` on publish
   - GitHub CLI: `gh release create v1.2.0`
4. The [workflow](../.github/workflows/rmskin.yml) verifies the tag matches `RMSKIN.ini`, builds the
   `.rmskin` with [2bndy5/rmskin-action](https://github.com/2bndy5/rmskin-action), and attaches it to the
   release.

`RMSKIN.ini` `VariableFiles` lists the base and every clone `Variables.inc` (pipe-separated) so per-window
styling survives an upgrade. To test a build without releasing, run the workflow manually (Actions ->
Package rmskin -> Run workflow); it produces a downloadable artifact and does not create a release. The
built `.rmskin` is git-ignored on purpose; distribute it through Releases, not the repo.
