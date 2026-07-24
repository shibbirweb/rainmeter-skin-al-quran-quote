## Context

The settings panel (capability `skin-settings`) already edits font, colors, opacity, and duration through
a font list, sliders, and a typed duration field, applying changes to the main skin via `!SetVariable`
(no refetch) and never refreshing itself. This change adds size control, a rotation toggle, reset, an
icon-overlap fix, and direct-entry alternatives for font/background-color/opacity. The main skin currently
uses a fixed `PanelWidth` and grows its height to fit the verse (`DynamicWindowSize=1` plus a shape-height
formula), and the WebParser rotates on `UpdateRate=#RotateEvery#`.

Constraints from CLAUDE.md apply: minimal, structure/config split, descriptive names, no bundled binaries,
no magic numbers, no nested ternaries, human-readable over clever.

## Goals / Non-Goals

**Goals:**
- Reset all settings to defaults from the panel.
- Auto or fixed panel width; auto or fixed panel height.
- Toggle automatic verse rotation on/off (click still fetches).
- Settings icon no longer overlaps the verse.
- Keep the existing font list / color sliders / opacity range AND add direct-entry inputs for font,
  background color, and opacity.

**Non-Goals:**
- A scrollable settings panel (Rainmeter has no native scroll; the panel simply grows taller).
- Content-fitting "shrink to text" width (see Open Questions); "auto" means the default automatic size.
- Per-verse pinning history or favorites.

## Decisions

### Decision: Resolve width in Lua, height with an arithmetic select in the skin

Width does not depend on rendered text, so `Settings.lua` resolves it: `WidthAuto` and `FixedWidth` are
panel state; when either changes, Lua writes the effective value into the existing `PanelWidth` variable
(`WidthAuto=1` -> `DefaultPanelWidth`; `WidthAuto=0` -> `FixedWidth`, clamped). The main skin keeps using
`#PanelWidth#` unchanged.

Height "auto" depends on the rendered verse height (`[MeterQuote:H]`), which Lua cannot know, so it is
selected in the shape formula with plain arithmetic (no ternary, which Rainmeter formulas lack):

```
height = #HeightAuto# * (autoHeightFormula) + (1 - #HeightAuto#) * #FixedHeight#
```

Because `HeightAuto` is 0 or 1 this picks one branch. `autoHeightFormula` is the current content formula
(now including the icon header gap, see below). When height is fixed, the verse meters keep `ClipString`
so overflow is clipped rather than resizing the window.

Alternative considered: resolve height in Lua too. Rejected because the auto height needs the live meter
height, which is only known after render.

### Decision: Drive rotation with a timer decoupled from the download (revised during apply)

An earlier plan fed a derived `EffectiveRate = AutoChange * RotateEvery` into the WebParser `UpdateRate`
and refreshed the main skin on change. That was implemented but caused a real bug: refreshing the main
skin makes the WebParser re-download, so toggling `AutoChange` (or changing the duration) refetched and
changed the displayed verse.

Revised approach: `[MeasureQuran]` uses `UpdateDivider=-1` (download once on load, never on its own
timer). A `Calc` measure `[MeasureRotateTick]` counts one per second and forces
`[!CommandMeasure MeasureQuran "Update"]` every `RotateEvery` seconds while `AutoChange` is 1:

```
Formula=((MeasureRotateTick + 1) % #RotateEvery#)
IfCondition=((MeasureRotateTick = 0) && (#AutoChange# = 1))
IfTrueAction=[!CommandMeasure MeasureQuran "Update"]
```

Both `RotateEvery` and `AutoChange` are read dynamically, so `Settings.lua` applies rotation changes with
`!SetVariable ... "AlQuranQuote"` only (no refresh, no refetch). Clicking the panel still fetches. This
removes `EffectiveRate` entirely.

Alternative considered: change the WebParser `UpdateRate` live via `!SetOption`. Rejected because a
WebParser reload can re-download, which is the very refetch we must avoid.

### Decision: Fix the icon overlap with a header gap

The verse currently starts at `Y=#Pad#`, under the top-right icon. Introduce `IconGap` and start the verse
below the icon: `QuoteTopY = #Pad# + #GearIconHeight# + #IconGap#`. The auto-height formula uses this top
offset instead of the first `#Pad#`. The icon stays in the top-right corner but no longer overlaps text.

### Decision: Checkboxes and reveal-on-uncheck inputs

A checkbox is a small Shape (a box, plus a check mark drawn when on) with a click action that calls a Lua
toggle (`toggleWidthAuto`, `toggleHeightAuto`, `toggleAutoChange`). For width/height, the fixed-value
input is shown only when "auto" is off, using the show/hide group pattern already used by the font list
(`!ShowMeterGroup` / `!HideMeterGroup` driven from Lua based on the toggle state).

### Decision: Direct-entry inputs reuse the existing apply paths

Add InputText controls beside the existing controls:
- Manual font -> `setFont(text)` (existing).
- Manual background color -> new `setBackgroundColorManual(text)`: split on commas, clamp each channel to
  0-255, update the `backgroundColor` Lua table, then reuse `applyBackgroundColor`.
- Manual opacity -> new `setOpacityValue(value)`: clamp to `MinPanelOpacity`-`MaxPanelOpacity`, then reuse
  the opacity apply path.
Each keeps the sliders/list in sync because they all read the same working variables that these handlers
update.

### Decision: Reset from a single defaults table in Lua

`Settings.lua` holds a `defaults` table (the canonical default for every tunable). `resetSettings()`
writes each default to `Variables.inc`, refreshes the main skin (needed for width/height/rate), and calls
`loadSettings()` to reseed the panel. Defaults mirror the initial values in `Variables.inc`.

### Decision: Relayout and grow the panel

The new controls (reset button, width row + input, height row + input, auto-change checkbox, three manual
inputs) are added as blocks; all block base-Y metrics and `SettingsHeight` are recomputed in
`SettingsTheme.inc`. The panel simply gets taller (no scroll).

## Risks / Trade-offs

- **Fixed height vs `DynamicWindowSize`.** With a fixed height smaller than the verse, the window could
  still grow if a meter extends past the shape. -> Keep `ClipString` on the verse and size the clickable
  panel from the shape; document that a too-small fixed height clips the verse.
- **"Auto" width is the default width, not content-fit.** -> Documented; content-fit is an open question.
- **Derived `EffectiveRate` must stay in sync with `RotateEvery`/`AutoChange`.** -> Recomputed on every
  change to either, and set by reset; defaulted in `Variables.inc`.
- **Panel keeps growing taller.** -> Acceptable for now; a future change could add pagination/sections.
- **Reset writes many keys then refreshes.** -> One refresh after all writes; infrequent action.

## Migration Plan

1. Add new tunables + defaults + bounds to `Variables.inc` (`WidthAuto`, `FixedWidth`, `HeightAuto`,
   `FixedHeight`, `AutoChange`, `EffectiveRate`, `DefaultPanelWidth`, `IconGap`, and Min/Max bounds).
2. Update `AlQuranQuote.ini`: verse top offset for the icon gap, arithmetic-select shape height,
   `UpdateRate=#EffectiveRate#`.
3. Extend `Settings.lua`: width/height/auto-change setters and toggles, manual entry handlers,
   `resetSettings`, and the `defaults` table; keep the no-self-refresh apply model.
4. Extend `Settings.ini` + `SettingsTheme.inc`: reset button, width/height rows with checkboxes and
   reveal-on-uncheck inputs, auto-change checkbox, manual font/color/opacity inputs; recompute layout.
5. Update `CLAUDE.md` and `CHANGELOG.md`.
6. Rollback: revert these files; the previously persisted tunables keep their shapes.

## Open Questions

- Should "auto" width fit the content (shrink/grow to the verse) instead of using the default width?
- For fixed height, should overflowing verses shrink the font to fit, or just clip (current plan: clip)?
- Reset: confirm the default set, especially `DefaultPanelWidth` (340), default font (Georgia), and
  `AutoChange` on by default.
