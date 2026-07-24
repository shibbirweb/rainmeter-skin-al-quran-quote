## Context

The skin is a minimal Rainmeter widget. All tunables live in `@Resources/Variables.inc` and today can
only be changed by hand-editing that file and refreshing. Rainmeter has no built-in settings dialog for
a custom skin, so a settings UI has to be built from Rainmeter primitives: meters for controls, the
bundled InputText plugin for typed values, mouse actions (bangs) for buttons, and `!WriteKeyValue` to
persist changes. This design describes how to add that UI while keeping the "structure vs. config" split
and the minimalism the project mandates.

Constraints carried from CLAUDE.md: keep it minimal; split structure (`.ini`) from config
(`Variables.inc`); descriptive names; no bundled font or image binaries; no magic numbers (name them in
`Variables.inc` or as Lua locals); no nested ternaries or clever shorthand.

## Goals / Non-Goals

**Goals:**
- Let the user change font family, font size, font style (Bold / Regular / Italic), font color,
  background color, background opacity, and quote change duration from inside the skin.
- Persist every change to `Variables.inc` so it survives refresh and Rainmeter restart.
- Apply changes to the running main skin immediately.
- Show current values when the panel opens.

**Non-Goals:**
- A graphical color wheel / eyedropper picker (Rainmeter has no native one). Colors are entered as RGB
  with optional preset swatches.
- Per-element styling of the reference line. Settings target the verse (quote) text, which is the
  prominent element in the issue #1 mockup. The reference keeps its fixed styling.
- Adding Arabic, multiple themes, or import/export of settings.

## Decisions

### Decision: A companion settings skin, not an inline panel

Add a second skin file `Settings.ini` in the same config folder (`Skins/AlQuranQuote/`). The main panel
gets a small gear affordance that toggles it via `[!ToggleConfig "AlQuranQuote\Settings" ...]` (or
`!ActivateConfig` / `!DeactivateConfig`). Keeping settings in their own skin file preserves the
"structure only" main `.ini`, keeps the main panel visually clean, and lets the settings window be
positioned and closed independently.

Alternative considered: an expanding section inside `AlQuranQuote.ini`. Rejected because it bloats the
main structure file with control logic and complicates the panel's auto-sizing.

### Decision: InputText plugin for typed values, buttons for the style choice

- Font family, font size, font color (RGB), background color (RGB), background opacity, and duration are
  edited with the bundled **InputText** plugin, launched by clicking each field. Numeric fields use
  `InputNumber=1`.
- Font style is a set of three labelled controls (Bold / Regular / Italic); clicking one writes the
  matching Rainmeter `StringStyle` keyword. This is clearer than an InputText for a fixed three-way
  choice and avoids free-text typos.

Alternative considered: a single cycling button for style. Rejected because three explicit buttons make
the current selection visible and need no state machine.

### Decision: Split background color into RGB + opacity variables

Today `PanelColor=18,22,28,205` bakes color and alpha into one value. To let opacity be edited
independently of color (a spec requirement), split it into:
- `PanelColorRGB` (e.g. `18,22,28`)
- `PanelOpacity` (alpha `0`-`255`)

The main skin composes them: `Fill Color #PanelColorRGB#,#PanelOpacity#`. The font color stays a single
RGBA value in `QuoteColor` because the request treats font color as one control (no separate font
opacity was requested).

### Decision: New `QuoteStyle` variable drives `StringStyle`

Introduce `QuoteStyle` (default `Italic`, matching today's hardcoded `StringStyle=Italic`). `MeterQuote`
changes to `StringStyle=#QuoteStyle#` with `DynamicVariables=1` (already set). The style buttons write
`Bold`, `Normal`, or `Italic` into `QuoteStyle`.

### Decision: Persist with `!WriteKeyValue`, then refresh, with clamping in Lua

Each control writes to `Variables.inc` via
`[!WriteKeyValue Variables <Key> "<Value>" "#@#Variables.inc"]` and then `[!Refresh "AlQuranQuote"]` to
apply. Numeric fields (size, opacity, duration) pass through a small `Settings.lua` helper that clamps
to named bounds before writing, so out-of-range or non-numeric input can never corrupt the skin. Bounds
(min/max font size, opacity range, min duration) are named constants, not magic numbers.

Alternative considered: rely only on InputText `InputNumber`. Rejected because it does not enforce
min/max, so a Lua clamp is still needed for the bounds the spec calls for.

### Decision: Settings skin reflects current values via shared variables

`Settings.ini` includes `@IncludeVariables=#@#Variables.inc` and uses `DynamicVariables=1`, so each
control's displayed value and each InputText `DefaultValue` come straight from the live variables. A
refresh after any write re-reads the file, keeping the panel in sync.

### Decision: Gear affordance uses a system font glyph

The open-settings control is a String meter showing a gear glyph (Unicode U+2699) in a system font,
honoring "no bundled image binaries". A tooltip labels it "Settings".

## Risks / Trade-offs

- **No native color picker; users type RGB triplets.** → Provide clear `R,G,B` labels, a tooltip with
  the expected format, and a few preset swatch buttons for common looks so typing is optional.
- **Splitting `PanelColor` into `PanelColorRGB` + `PanelOpacity` changes `Variables.inc` keys.** →
  This ships in a new release; defaults reproduce the current look exactly (`18,22,28` + `205`).
  Document the change in `CHANGELOG.md`. Fresh installs and the packaged `.rmskin` carry the new keys.
- **`!Refresh` reloads the main skin, briefly showing "Loading verse..." and refetching a verse.** →
  Acceptable minor flash; the rotation timer and offline fallback are unaffected. Note it in the task
  test steps.
- **InputText plugin dependency.** → InputText ships with Rainmeter; no extra install. Note the minimum
  Rainmeter version if relevant.
- **Invalid font family names silently fall back to a default font in Rainmeter.** → Acceptable; the
  clamp helper only guards numeric fields. Tooltip advises using an installed font name.

## Migration Plan

1. Add `QuoteStyle`, `PanelColorRGB`, and `PanelOpacity` to `Variables.inc` with defaults equal to the
   current appearance; remove the combined `PanelColor` once meters reference the new keys.
2. Update `AlQuranQuote.ini` meters to use the new variables and add the gear affordance.
3. Add `Settings.ini` and `@Resources/Scripts/Settings.lua`.
4. Verify packaging includes the new files (they live under `Skins/AlQuranQuote/`, which the rmskin
   packager already bundles).
5. Rollback: revert the new files and restore the combined `PanelColor` line; no data migration needed
   since everything lives in the versioned `Variables.inc`.

## Open Questions

- Should the settings also style the reference line, or only the verse? (Current design: verse only.)
- Do we want preset swatches in addition to RGB entry for v1, or defer swatches to a follow-up?
- Preferred open affordance: gear glyph on the panel (current design) vs. a right-click context-menu
  entry vs. both?
