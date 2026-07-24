## Why

The first settings panel (change `add-settings-ui`) works but is rough in practice: the gear and close
icons render as garbled text (`âœ•`) because the `.ini` is read as ANSI rather than UTF-8, long labels
overlap their values, and every control is a raw text field. Typing exact font names, RGBA triplets, and
opacity numbers is error-prone. Users expect to pick a font from a list, choose colors with a picker, and
drag a range for opacity. Editing a value also currently refreshes the settings panel itself, so the tool
visibly disturbs itself while in use.

## What Changes

- **Fix the icon rendering bug**: replace the Unicode gear/close glyphs with vector Shape-drawn icons
  (encoding-proof, no font or image binary), so the open and close controls always render correctly.
- **Fix the label/value overlap**: relayout each setting row so labels never collide with their controls.
- **Font selection from a list**: replace the free-text font field with a curated, clickable list of
  common, widely-installed fonts. (Dynamic enumeration of installed fonts is intentionally out of scope.)
- **Color picker for font color and background color**: replace the RGBA text fields with red/green/blue
  (and alpha, for font color) sliders and a live color preview swatch.
- **Opacity as a range**: replace the numeric opacity field with a draggable/clickable range control.
- **Decouple the settings UI from the values it edits**: the settings panel's own appearance is driven by
  its own theme file, never by the edited skin variables, and changing a value no longer refreshes or
  redraws the settings panel; only the main skin updates.

## Capabilities

### New Capabilities
<!-- No brand-new capability; this refines the existing skin-settings capability. -->

### Modified Capabilities
- `skin-settings`: The settings panel gains a font-selection list, a slider-based color picker (with live
  preview) for font and background color, and a range control for background opacity; the open/close
  icons become vector shapes; row layout is fixed so labels never overlap values; and the panel's own
  styling is isolated from the values it edits (no self-refresh on change).

## Impact

- `Skins/AlQuranQuote/Settings/Settings.ini`: new controls (font list, color sliders, opacity range),
  relayout, Shape-drawn close icon, working variables for live color/opacity state.
- `Skins/AlQuranQuote/AlQuranQuote.ini`: Shape-drawn settings (open) icon replacing the gear glyph.
- `Skins/AlQuranQuote/@Resources/Scripts/Settings.lua`: parse current color/opacity into slider
  components on open, compose components back into `QuoteColor` / `PanelColorRGB` / `PanelOpacity` on
  change, and apply to the main skin without refreshing the settings panel.
- New settings-UI theme file (for example `Settings/@Resources/SettingsTheme.inc` or an include) that
  holds only the panel's own look, kept separate from the skin's `@Resources/Variables.inc`.
- `Skins/AlQuranQuote/@Resources/Variables.inc`: unchanged tunables; still the single source of truth for
  what the panel edits.
- File encoding: any `.ini` containing non-ASCII must be saved as UTF-8 with BOM (or use only ASCII plus
  Shape icons).
- `CLAUDE.md` and `CHANGELOG.md`: document the new controls and the encoding requirement.
