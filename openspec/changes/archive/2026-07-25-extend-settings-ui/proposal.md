## Why

The settings panel covers appearance and rotation, but users still cannot reset to defaults, control the
panel's size, or stop auto-rotation, and the settings icon overlaps the verse. Some also want to type
exact values (font name, background RGB, opacity) rather than only using the list/sliders. These additions
make the skin fully self-serve without editing files.

## What Changes

- **Reset settings**: a button that restores every tunable to its default and applies it.
- **Width control**: an "auto" checkbox; when unchecked, an input sets a fixed panel width in pixels.
- **Height control**: an "auto" checkbox; when unchecked, an input sets a fixed panel height in pixels.
- **Automatic rotation toggle**: a checkbox to turn auto-changing the verse on or off; when off, the verse
  stays put (clicking the panel still fetches the next verse).
- **Fix the settings icon overlap**: add spacing so the icon on the main panel no longer overlaps the
  verse text.
- **Manual font entry**: keep the curated font list and add an input to type a font name directly.
- **Manual background color entry**: keep the RGB sliders and add an input to type `R,G,B` directly.
- **Manual background opacity entry**: keep the range slider and add an input to type the opacity value
  directly.

## Capabilities

### New Capabilities
<!-- None; this extends the existing skin-settings capability. -->

### Modified Capabilities
- `skin-settings`: Adds reset-to-defaults, fixed/auto panel width and height, an automatic-rotation
  toggle, and a non-overlapping settings icon; and extends the font family, background color, and
  background opacity controls with a direct-entry option alongside the existing list/sliders.

## Impact

- `Skins/AlQuranQuote/@Resources/Variables.inc`: new tunables (`WidthAuto`, `FixedWidth`, `HeightAuto`,
  `FixedHeight`, `AutoChange`) and their bounds/defaults; a place to define default values for reset.
- `Skins/AlQuranQuote/AlQuranQuote.ini`: panel width/height driven by the auto/fixed variables, the
  WebParser `UpdateRate` gated by `AutoChange`, and the settings icon repositioned with a gap from the
  verse.
- `Skins/AlQuranQuote/Settings/Settings.ini`: new controls (reset button, width/height auto checkboxes +
  inputs, auto-change checkbox, manual font/background-color/opacity inputs) and layout growth.
- `Skins/AlQuranQuote/Settings/@Resources/SettingsTheme.inc`: layout metrics for the new controls.
- `Skins/AlQuranQuote/@Resources/Scripts/Settings.lua`: reset handler, width/height/auto-change setters,
  and manual-entry handlers that validate and reuse the existing apply path.
- `CLAUDE.md` and `CHANGELOG.md`: document the new settings.
