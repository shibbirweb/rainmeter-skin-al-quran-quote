## Context

The settings capability is implemented and its main spec is synced. This change is a set of refinements to
the main skin and settings panel. Current relevant state: the reference is built in Lua as
`"Quran " .. verseKey` and pushed into `RefText`; the panel border is `PanelBorder=255,255,255,25` (RGBA in
one value); the settings icon is always visible; `[MeterPanel]` has `LeftMouseUpAction` that fetches the
next verse; the default `QuoteStyle` is `Italic`; checkboxes and labels are drawn at the same Y (slightly
misaligned).

Constraints from CLAUDE.md apply: minimal, structure/config split, descriptive names, no bundled binaries,
no magic numbers, no nested ternaries, human-readable over clever, keep files ASCII.

## Goals / Non-Goals

**Goals:**
- Editable reference label (default "Al Quran"), applied live to online and offline verses.
- Border opacity independent of border color.
- Show/hide the settings icon; reopen via Rainmeter when hidden.
- Vertically aligned checkbox + label.
- A dedicated next-verse control by the reference; full-window click no longer changes the verse.
- Default font style Regular.

**Non-Goals:**
- An in-skin way to reopen settings when the icon is hidden (the user reopens via Rainmeter's Manage
  dialog, by design).
- Changing the offline `quotes.txt` format.

## Decisions

### Decision: Compose the reference from variables so the label applies live

Store the verse key in a `VerseKey` variable and render the reference meter as `#ReferenceLabel# #VerseKey#`
(with `DynamicVariables=1`). `Verse.lua`'s `applyVerse(quoteText, verseKey)` sets `QuoteText` and
`VerseKey`. `Online()` passes the WebParser verse key. `Offline()` extracts the key from the bundled
reference with `string.match(reference, '%d+:%d+')` (so any leading word in `quotes.txt` still yields the
chapter:verse). Because the meter reads `#ReferenceLabel#` dynamically, changing the label in settings
updates the shown reference immediately without refetching.

Alternative considered: keep building the full `RefText` string in Lua. Rejected because then changing the
label would not update the current verse until the next fetch.

### Decision: Split the border into color + opacity

Replace `PanelBorder` with `PanelBorderRGB` (e.g. `255,255,255`) and `PanelBorderOpacity` (e.g. `25`). The
panel shape stroke becomes `Stroke Color #PanelBorderRGB#,#PanelBorderOpacity#`. The settings panel edits
`PanelBorderOpacity` with a slider (reusing the slider component) plus a manual entry, bounded by
`MinPanelOpacity`-`MaxPanelOpacity` (shared with background opacity).

### Decision: Icon visibility via a single bound variable

Use `SettingsIconHidden` (0 shown, 1 hidden). The main icon meter sets `Hidden=#SettingsIconHidden#`
(`DynamicVariables=1`). The settings checkbox is labelled "show settings icon" and is checked when the icon
is shown; its check-mark alpha uses `(1 - #SettingsIconHidden#) * 255`. `Settings.lua`'s `toggleShowIcon`
flips `SettingsIconHidden`, persists it, and sets it live on the main skin. When hidden, the panel is
reopened by activating `AlQuranQuote\Settings` from Rainmeter (documented, not an in-skin gesture).

### Decision: Vertically center checkbox labels

Draw each checkbox label at `Y = checkboxY + (#CheckboxSize# - #SettingsFontSize#) / 2` so the text centers
against the box. This uses named metrics (no magic numbers) and fixes the current misalignment.

### Decision: Dedicated next-verse control; remove full-window click

Remove `LeftMouseUpAction` from `[MeterPanel]`. Add a small next-verse icon meter drawn as a vector Shape
(a right-pointing "play"/next triangle via a `Path`) positioned on the reference line at the right of the
panel (`Y=[MeterReference:Y]`), with `LeftMouseUpAction=[!CommandMeasure MeasureQuran "Update"]` and a
"Next verse" tooltip. The window stays draggable (Rainmeter default); it just no longer changes the verse
on click.

Alternative considered: a circular "refresh" arrow. Rejected for v1 as an Arc `Path` is fiddly; a triangle
reads clearly as "next" and is simple to draw.

### Decision: Default font style Regular

Change the default `QuoteStyle` to `Normal` in `Variables.inc`, in `Settings.lua`'s `defaults` table, and
in the settings-UI working default. Existing installs keep their saved value; new installs and Reset get
Regular.

## Risks / Trade-offs

- **Offline key extraction depends on a `chapter:verse` pattern.** -> `quotes.txt` already uses
  "Quran X:Y"; the `%d+:%d+` match is robust to the leading word. If a line lacks that pattern, fall back
  to the raw reference string.
- **`[MeterReference:Y]` section variable may lag one cycle.** -> Acceptable; the next-verse icon settles
  immediately in practice and both use `DynamicVariables`.
- **`Hidden=#SettingsIconHidden#` must be dynamic.** -> The icon meter carries `DynamicVariables=1`; the
  settings toggle sets the variable live on the main config.
- **Panel grows taller with the new controls.** -> Recompute block base-Y metrics and `SettingsHeight`;
  no scroll (consistent with the current panel).

## Migration Plan

1. Add/repl tunables in `Variables.inc` (`ReferenceLabel`, `VerseKey`, `PanelBorderRGB`/
   `PanelBorderOpacity`, `SettingsIconHidden`, `QuoteStyle=Normal`).
2. Update `AlQuranQuote.ini`: reference meter, border stroke, icon `Hidden`, next-verse control, remove
   full-window click.
3. Update `Verse.lua`/`RandomAyah.lua` for the `VerseKey` variable and offline key extraction.
4. Extend `Settings.lua` (`setReferenceLabel`, `setBorderOpacity*`, `toggleShowIcon`, updated defaults and
   seeding) and `Settings.ini`/`SettingsTheme.inc` (new controls, alignment, layout).
5. Update `CLAUDE.md` and `CHANGELOG.md`.
6. Rollback: revert these files; persisted tunables keep their shapes (border split mirrors the background
   split already shipped).

## Open Questions

- Should the next-verse control be a triangle (planned) or a refresh/circular-arrow icon?
- Should the reference label also be applied retroactively to the offline `quotes.txt` content, or only
  via live composition (planned: live composition from `ReferenceLabel` + `VerseKey`)?
