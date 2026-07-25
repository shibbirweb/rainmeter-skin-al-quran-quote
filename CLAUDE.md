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
   download, so no cache-buster is needed. It downloads once on load; rotation and the next-verse click
   both fetch by running `[!CommandMeasure MeasureQuran "Update"][!UpdateMeasure MeasureQuran]`. See the
   rotation note below.
2. Child measures extract fields via `StringIndex` from the regex
   `(?siU)"verse_key":"(.*)".*"text":"(.*?)"`: `MeasureKey` (1) = verse_key, `MeasureEnglish` (2) =
   translation (HTML tags stripped via `RegExpSubstitute`). The text group is greedy (`(.*?)` under the
   `(?U)` flag) so it runs to the real closing quote; a lazy group would stop at the first escaped quote
   inside verses that contain quotation marks (e.g. 23:47) and truncate them. `Online()` then converts the
   API's `\"` and `\/` escapes back to `"` and `/`.
3. On success `FinishAction` calls `Online()`, which reads the child measures and calls
   `applyVerse(english, verseKey)`. On error, `On*ErrorAction` calls `Offline()`, which shows the NEXT
   line of `quotes.txt` (a module-level `offlineIndex` advances and wraps, so offline verses cycle
   sequentially), split on `|` into `quote | reference` with the reference shown verbatim (see the
   reference note below). `Offline()` re-reads the file every call, so edits to `quotes.txt` appear on the
   next verse change with no refresh. When `#CustomVerseEnabled#` is 1, both route to `applyCustomVerse()`.
4. `applyVerse(quoteText, verseKey, useLabel)` sets `#QuoteText#`, `#VerseKey#` and `#RefUseLabel#`, then
   composes `#RefText#` (in `Verse.lua`'s `composeReferenceText`) from the label, the key and the two show
   toggles. The quote meter shows `#QuoteText#`; the reference meter shows `#RefText#`. Composing in Lua
   (not `#ReferenceLabel# #VerseKey#` in the meter) lets either part be hidden and drops the trailing space
   so a lone label stays centered. `useLabel` is true for online and custom verses (label may prefix the
   key) and false for offline verses, whose reference from `quotes.txt` is shown verbatim with no label;
   `refreshReference` reads `#RefUseLabel#` so a later toggle change recomposes the same way. The settings
   panel changes the label/toggles/custom fields and then calls `refreshDisplay()` on the main skin (via
   cross-config `!CommandMeasure`), which recomposes without refetching.

Gotcha: do NOT put `DynamicVariables=1` on the `[MeasureQuran]` WebParser parent. WebParser downloads
on a background thread; with `DynamicVariables=1` it re-reads the URL every update and the download
never settles, so `FinishAction` never fires and the skin stays on "Loading verse...".

Verse source: the next-verse control and the rotation tick both call `RandomAyah.lua`'s `nextVerse()`,
which picks the source: the custom verse if `#CustomVerseEnabled#` is 1, else an online download if
`#OnlineFetchEnabled#` is 1 (`CommandMeasure MeasureQuran "Update"` + `!UpdateMeasure`), else a new offline
verse from `quotes.txt`. When online fetching is off, `Online()` ignores the one background download that
still happens on load (it returns early), and `Initialize` shows an offline verse immediately. The settings
panel's "open fallback file" control runs `[notepad "#ROOTCONFIGPATH#@Resources\quotes.txt"]` so the user
can edit the offline verses; `Offline()` re-reads the file each time, so no refresh is needed.

Custom verse: when `#CustomVerseEnabled#` is 1 the skin shows the user's `#CustomText#` with the manual
`#SuraNumber#:#VerseNumberManual#` as the reference key, instead of fetching. Both numbers are nullable: if
either is empty the key is empty and the reference shows just the label (centered). `RandomAyah.lua`'s
`Online`/`Offline`/`refreshDisplay`/`nextVerse` route to `applyCustomVerse()` in this mode, the rotation
tick is gated off (`&& (#CustomVerseEnabled# = 0)`), and the next-verse control is hidden
(`Hidden=#CustomVerseEnabled#`), so a stray download can never overwrite the custom verse. Toggling the mode
off calls `nextVerse()` to show a fresh verse. `#ShowReferenceLabel#` and `#ShowVerseNumber#` toggle the two
parts of the reference line and apply in both modes. The three text inputs (custom text, sura, verse) write
`$UserInput$` into a working variable and then call a `commit*` Lua function that reads it back, so an
apostrophe in the text cannot break the command (double quotes still can, a Rainmeter InputText limit).

Gotcha: `[MeasureQuran]` sets `ProxyServer=/none`. WebParser defaults to the system/IE proxy config, so on
a machine with proxy auto-detection (WPAD) enabled the download can hang indefinitely: the log shows
`Fetching:` but no `Finished` and no error action ever fires (neither `OnConnectErrorAction`,
`OnDownloadErrorAction`, nor `OnRegExpErrorAction` runs on a hang), so the skin stays on "Loading
verse...". The value must be exactly `/none` with the leading slash: WebParser maps `/none` to a direct
connection (`INTERNET_OPEN_TYPE_DIRECT`) and `/auto` to the system proxy; any other string (including
`None` without the slash) is treated as a literal proxy hostname and still hangs. Do NOT remove it or drop
the slash.

Settings panel: the settings icon on the main panel toggles `AlQuranQuote\Settings` (Settings.ini) via
`!ToggleConfig`. It lives in the `Settings/` subfolder on purpose: a subfolder is a separate Rainmeter
config, so it runs alongside the main skin. A sibling `.ini` in the same folder would be a variant of the
same config and would replace the main panel instead. The panel reads two variable files: its own
`Settings\@Resources\SettingsTheme.inc` (its look, layout, curated font list, and working state) and the
parent `@Resources\Variables.inc` via `#ROOTCONFIGPATH#` (only to seed the controls with current values).
Keeping the panel's look in its own file is deliberate: editing the skin never restyles the panel.

Controls: the Text tab has a full font control set for BOTH the Quote (left column) and the Reference
(right column): a click-to-open curated font list (plus a manual "type a font name" input), a font-size
slider, three font-style buttons (Bold / Regular / Italic), and an R/G/B/A color picker (preview + four
sliders + manual entry). The quote applies to `QuoteFont`/`QuoteSize`/`QuoteStyle`/`QuoteColor`, the
reference to `RefFont`/`RefSize`/`RefStyle`/`RefColor`; the Lua functions mirror each other
(`setFont`/`setRefFont`, `setStyle`/`setRefStyle`, `setFontColorChannel`/`setRefColorChannel`, etc.) and
the single font-list overlay is shared via `FontListTarget`/`FontListX`. Other controls: a range slider for
background color/opacity and border opacity (plus manual inputs), an editable reference label, show/hide
checkboxes for the reference label and
the verse number, a "use custom verse" checkbox with a custom-text input and optional sura/verse number
inputs, a typed rotation duration, "auto" checkboxes for width and height (each revealing a fixed-value
input when unchecked), an automatic-rotation checkbox, show-settings-icon and show-next-verse-icon
checkboxes, a "Change verse" button (shows the next verse; useful when the icon is hidden), and a Reset
button.
Sliders are Shape meters (track + fill); click sets the value from
`$MouseX:%$` (position as a percentage of the meter) and the scroll wheel nudges by a named step.
Checkboxes are Shape meters whose check mark alpha is driven by the bound variable (`... * 255`), with a
near-transparent fill so the whole box is clickable. Reveal-on-uncheck inputs use the `WidthInput` /
`HeightInput` groups shown/hidden from Lua. Live state lives in settings-owned working variables
(`WorkFontSize`, `FontColorR..A`, `WorkFontFamily`, `WorkStyle`, and the reference mirror
`WorkRefFontSize`, `RefColorR..A`, `WorkRefFontFamily`, `WorkRefStyle`; plus `BgColorR..B`, `WorkOpacity`,
`WorkDuration`, `WidthAuto`, `FixedWidth`, `HeightAuto`, `FixedHeight`, `AutoChange`, `WorkCustomText`,
`WorkSuraNumber`, `WorkVerseNumber`) plus the shared toggles
`ShowReferenceLabel`/`ShowVerseNumber`/`CustomVerseEnabled`,
that `Settings.lua` seeds on open. The panel is split into three tabs (Text / Panel / Verse) so it stays
short; each content meter is in a `Tab1`/`Tab2`/`Tab3` group (multiple groups joined with `|`, e.g.
`Group=Live | Tab1`), `setTab(n)` hides the other two groups and shows the active one, and Tab2/Tab3 meters
start `Hidden=1` so only Tab1 shows on open. The font-list overlay and the reveal-on-uncheck width/height
inputs are NOT in a Tab group; `setTab` hides them explicitly (and re-shows width/height on the Panel tab
only when their auto box is unchecked) so they never appear on the wrong tab. Within a tab the controls sit
in two columns with independent base-Y stacks (starting from `ContentTopY`) in `SettingsTheme.inc`. The
Text tab groups by role: Quote in the left column (X=`Pad`, using `SliderX`/`SliderValueX`/`PreviewX`) and
Reference in the right column (X=`Col2X`, using the `*X2` mirror metrics `SliderX2`/`SliderValueX2`/
`SliderChannelLabelX2`/`PreviewX2`), so both columns hold sliders. The Panel and Verse tabs instead keep
slider-based controls on the left and flat controls on the right. Adding a control means recomputing the
base-Y of the ones below it in the same column and, if it grows the tallest column across all tabs,
`ResetBaseY` and `SettingsHeight`.

Apply path (in `Settings.lua`): on any change it writes the value to the parent `Variables.inc` with
`!WriteKeyValue`, then applies it to the running main skin. Appearance changes (font, size, style, colors,
opacity, width, height, and rotation) use `!SetVariable ... "AlQuranQuote"` (plus `!UpdateMeter`/`!Redraw`
for appearance) so the verse does NOT refetch. Reference/custom changes (label, show toggles, custom text,
sura/verse) use `applyMainRefresh`, which sets the variable on the main skin and then calls
`refreshDisplay()` there to recompose `#RefText#` (and re-apply the custom verse) without refetching. Only
Reset uses `!Refresh "AlQuranQuote"`. Width is
resolved in Lua and written to `PanelWidth` (auto -> `DefaultPanelWidth`, fixed -> clamped `FixedWidth`);
height cannot be resolved in Lua (auto height depends on the rendered verse), so the panel shape selects
it with arithmetic: `#HeightAuto# * (autoFormula) + (1 - #HeightAuto#) * #FixedHeight#`.

Rotation is decoupled from the download so toggling rotation or changing the duration never refetches the
displayed verse. `[MeasureRotateTick]` (a `Calc`, `DynamicVariables=1`) counts one per second and wraps to
0 every `RotateEvery` seconds via `(MeasureRotateTick + 1) % #RotateEvery#`; when it hits 0 and
`#AutoChange#` is 1 it fires `[!CommandMeasure MeasureQuran "Update"][!UpdateMeasure MeasureQuran]`.
`Settings.lua`'s `applyRotation` persists `AutoChange`/`RotateEvery` and applies them live with
`!SetVariable ... "AlQuranQuote"` (NO refresh); the tick reads both dynamically, so a change takes effect on
the next tick. Only Reset uses `!Refresh` (which does refetch).

The WebParser must keep updating for this to work, so it uses `UpdateRate=#DownloadOnDemandRate#` (a very
large value), NOT `UpdateDivider=-1`. Why: `CommandMeasure "Update"` only resets the WebParser's internal
counter; the actual download runs inside the measure's next `UpdateValue`, i.e. on its next update. With
`UpdateDivider=-1` the measure never updates again, so `Update` (both rotation and the click) silently
downloads nothing. A large non-zero `UpdateRate` keeps the counter climbing so the WebParser never
auto-downloads on its own timer, while `Command "Update"` (paired with `!UpdateMeasure` to force the update
this tick) still fetches on demand. Do NOT use `UpdateRate=0`: that makes the counter reset to 0 every
update, so it refetches every second and the downloads thrash and never settle (stuck on "Loading
verse..."). This is the pitfall an earlier decoupled attempt hit; the fix is a large non-zero rate plus
`!UpdateMeasure`, not `UpdateDivider=-1` and not `0`. Reset restores a `defaults` table in `Settings.lua`.
The settings panel is never refreshed; its
previews update in place via `!UpdateMeter`/`!Redraw`, and `loadSettings()`/`resetSettings()` share one
`seedWorkingState` helper (never read a variable back right after `!SetVariable` in the same call). Because
the panel reloads its `Initialize` each time it is toggled on, it always opens showing current values. Do
NOT reintroduce a self-refresh of the settings config.

Main panel layout: the verse starts below the settings icon (`Y = #Pad# + #GearIconHeight# + #IconGap#`)
so the icon never overlaps the text.

Icons are vector Shapes, not font glyphs: the main panel's open icon is three lines with knobs and the
panel's close icon is a crossed X. This avoids the mojibake that appears when a `.ini` with non-ASCII
glyphs is read as ANSI. Keep the `.ini`/`.inc` files ASCII; if any ever needs non-ASCII, save it as UTF-8
with a BOM (Rainmeter reads UTF-8 without a BOM as ANSI).

Unicode in verse text: `RandomAyah.lua` is saved as UTF-16 LE with a BOM. A Rainmeter Lua script is only
treated as Unicode when its file starts with the UTF-16 LE BOM (`0xFF 0xFE`); otherwise every string that
crosses the Rainmeter<->Lua boundary (`GetStringValue`, `GetVariable`, `!SetVariable`) is converted with
the ANSI codepage, which turns non-ASCII characters the API returns (e.g. the `ā`/`ī` in "Allāh") into `?`.
Because `MeasureRandom` owns that script, its Unicode flag governs the whole verse pipeline, including
`applyVerse` in the dofile'd `Verse.lua`; those helper files and `quotes.txt` stay UTF-8 (offline lines are
read as UTF-8 bytes and marshaled through `MeasureRandom`'s Unicode scope). Editing a UTF-16 file with the
plain text tools can be awkward; convert to UTF-8, edit, then convert back to UTF-16 LE with BOM, or edit it
via a script. A verse still needs a `QuoteFont` that has glyphs for the script (Georgia covers Latin incl.
`ā`/`ī`; for Arabic or other scripts pick a suitable font in the settings). The settings-panel Lua
(`Settings.lua`) is still ASCII, so typing non-ASCII custom text / reference label is not yet Unicode-safe;
that would need the same UTF-16 treatment plus a UTF-8-BOM `Variables.inc` for persistence.

Background color and border are each stored as RGB + opacity (`PanelColorRGB`/`PanelOpacity` and
`PanelBorderRGB`/`PanelBorderOpacity`), so color and opacity change independently; the panel fill composes
`#PanelColorRGB#,#PanelOpacity#` and the stroke `#PanelBorderRGB#,#PanelBorderOpacity#`. `QuoteStyle` holds
a Rainmeter `StringStyle` keyword (`Bold`, `Normal`, or `Italic`); the default is `Normal` (Regular).

The settings icon on the quote window is hidden when `SettingsIconHidden=1` (its meter is
`Hidden=#SettingsIconHidden#`); when hidden, the settings panel is reopened by loading `AlQuranQuote\Settings`
from Rainmeter's Manage dialog. The verse is changed by a small next-verse control (a vector chevron) on
the reference line, NOT by clicking the window (the panel has no click action; it stays draggable). That
control is hidden while a custom verse is shown OR when `NextIconHidden=1`; its meter combines the two with
`Hidden=(1 - (1 - #CustomVerseEnabled#) * (1 - #NextIconHidden#))` (Rainmeter's `Hidden` parses a
parenthesized formula). When the icon is hidden, the settings Verse tab's "Change verse" button
(`[!CommandMeasure MeasureRandom "nextVerse()" "AlQuranQuote"]`) changes the verse instead.

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
  stamps that value into both skins' `[Metadata] Version` (`AlQuranQuote.ini` and `Settings/Settings.ini`)
  at build time (do not hand-edit `[Metadata] Version`), and on a `v*` tag CI fails the release if the tag
  does not match `RMSKIN.ini`. The git tag and the `CHANGELOG.md` heading must equal the `RMSKIN.ini`
  version.
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

Append a line to `@Resources/quotes.txt` in the form `quote | reference`. The line is split on the first
`|`: the left side is the quote, the right side is the reference, shown verbatim (no label prefix, not
parsed). For example `Alhumdulillah | ABC DE` shows "Alhumdulillah" with the reference "ABC DE". Use the
"Open file in Notepad" control on the settings Verse tab to edit this file.
