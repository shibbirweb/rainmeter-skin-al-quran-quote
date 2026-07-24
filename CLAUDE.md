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
  AlQuranQuote.ini            Main skin structure: [Rainmeter], [Metadata], measures, meters, settings icon.
  Settings/
    Settings.ini              Settings panel (a child config toggled by the settings icon). Font list,
                              color sliders, opacity range; applies changes via Settings.lua.
    @Resources/
      SettingsTheme.inc       The panel's OWN look + layout + curated font list + working state. Separate
                              from the skin's Variables.inc so editing the skin never restyles the panel.
  @Resources/
    Variables.inc             All tunables (colors, fonts, sizes, styles, RotateEvery, bounds). Themed here.
    Scripts/RandomAyah.lua     Entry points: Initialize, Update, Online, Offline.
    Scripts/Verse.lua          applyVerse(quote, ref): sets display vars, repaints.
    Scripts/QuoteFile.lua      readLines(path), parseLine(line): offline file I/O and parsing.
    Scripts/Settings.lua       Backs the settings panel: seed working vars on open, apply changes to the
                              main skin (no refetch), no self-refresh of the panel.
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

Settings panel: the settings icon on the main panel toggles `AlQuranQuote\Settings` (Settings.ini) via
`!ToggleConfig`. It lives in the `Settings/` subfolder on purpose: a subfolder is a separate Rainmeter
config, so it runs alongside the main skin. A sibling `.ini` in the same folder would be a variant of the
same config and would replace the main panel instead. The panel reads two variable files: its own
`Settings\@Resources\SettingsTheme.inc` (its look, layout, curated font list, and working state) and the
parent `@Resources\Variables.inc` via `#ROOTCONFIGPATH#` (only to seed the controls with current values).
Keeping the panel's look in its own file is deliberate: editing the skin never restyles the panel.

Controls: a click-to-open curated font list (plus a manual "type a font name" input), sliders for font
size and for each color channel (font color R/G/B/A, background R/G/B), a range slider for background
opacity (plus manual inputs for font color R,G,B,A, background R,G,B, and opacity), three buttons for font
style, a typed rotation duration,
"auto" checkboxes for width and height (each revealing a fixed-value input when unchecked), an automatic-
rotation checkbox, and a Reset button. Sliders are Shape meters (track + fill); click sets the value from
`$MouseX:%$` (position as a percentage of the meter) and the scroll wheel nudges by a named step.
Checkboxes are Shape meters whose check mark alpha is driven by the bound variable (`... * 255`), with a
near-transparent fill so the whole box is clickable. Reveal-on-uncheck inputs use the `WidthInput` /
`HeightInput` groups shown/hidden from Lua. Live state lives in settings-owned working variables
(`WorkFontSize`, `FontColorR..A`, `BgColorR..B`, `WorkOpacity`, `WorkFontFamily`, `WorkDuration`,
`WidthAuto`, `FixedWidth`, `HeightAuto`, `FixedHeight`, `AutoChange`) that `Settings.lua` seeds on open.

Apply path (in `Settings.lua`): on any change it writes the value to the parent `Variables.inc` with
`!WriteKeyValue`, then applies it to the running main skin. Appearance changes (font, size, style, colors,
opacity, width, height, and rotation) use `!SetVariable ... "AlQuranQuote"` (plus `!UpdateMeter`/`!Redraw`
for appearance) so the verse does NOT refetch. Only Reset uses `!Refresh "AlQuranQuote"`. Width is
resolved in Lua and written to `PanelWidth` (auto -> `DefaultPanelWidth`, fixed -> clamped `FixedWidth`);
height cannot be resolved in Lua (auto height depends on the rendered verse), so the panel shape selects
it with arithmetic: `#HeightAuto# * (autoFormula) + (1 - #HeightAuto#) * #FixedHeight#`.

Rotation is decoupled from downloads. `[MeasureQuran]` has `UpdateDivider=-1` (download once on load,
never on its own timer). `[MeasureRotateTick]` (a `Calc` that counts one per second) forces
`[!CommandMeasure MeasureQuran "Update"]` every `RotateEvery` seconds while `AutoChange` is 1; both are
read dynamically, so changing the duration or toggling rotation takes effect immediately with NO refresh
and NO refetch of the current verse. Do NOT go back to gating rotation through the WebParser's own
download timer: changing that needs a refresh, which refetches (and toggling rotation must never change
the displayed verse). Reset restores a `defaults` table in `Settings.lua`. The settings panel is never
refreshed; its
previews update in place via `!UpdateMeter`/`!Redraw`, and `loadSettings()`/`resetSettings()` share one
`seedWorkingState` helper (never read a variable back right after `!SetVariable` in the same call). Because
the panel reloads its `Initialize` each time it is toggled on, it always opens showing current values. Do
NOT reintroduce a self-refresh of the settings config.

Main panel layout: the verse starts below the settings icon (`Y = #Pad# + #GearIconHeight# + #IconGap#`)
so the icon never overlaps the text.

Icons are vector Shapes, not font glyphs: the main panel's open icon is three lines with knobs and the
panel's close icon is a crossed X. This avoids the mojibake that appears when a `.ini` with non-ASCII
glyphs is read as ANSI. Keep the skin files ASCII; if any file ever needs non-ASCII, save it as UTF-8 with
a BOM (Rainmeter reads UTF-8 without a BOM as ANSI).

Background color is stored as two variables, `PanelColorRGB` and `PanelOpacity`, so opacity can be changed
without touching the color; the panel fill composes them as `#PanelColorRGB#,#PanelOpacity#`. `QuoteStyle`
holds a Rainmeter `StringStyle` keyword (`Bold`, `Normal`, or `Italic`).

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
