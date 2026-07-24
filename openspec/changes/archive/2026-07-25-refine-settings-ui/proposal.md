## Why

With the settings panel in place, a few refinements make the widget more polished and personal: the
reference label is hardcoded as "Quran" (should be editable, defaulting to "Al Quran"), the panel border
opacity cannot be changed, the settings icon cannot be hidden, the checkbox labels sit slightly out of
alignment, and clicking anywhere in the window changes the verse (too easy to trigger by accident). The
default font style should also be Regular rather than Italic.

## What Changes

- **Editable reference label**: replace the hardcoded "Quran" prefix with a `ReferenceLabel` setting,
  default "Al Quran" (so the reference reads e.g. "Al Quran 6:124"). Editable from the settings panel.
- **Border opacity**: add a setting for the rounded panel border opacity (split the border color into RGB
  plus an opacity value, like the background).
- **Show/hide the settings icon**: a checkbox to show or hide the settings icon on the quote window. When
  hidden, the settings panel is reopened by loading the `AlQuranQuote\Settings` skin from Rainmeter's
  Manage dialog.
- **Checkbox/label alignment**: vertically center each checkbox with its label in the settings panel.
- **Change-verse control**: add a small control next to the reference (ayah number) that fetches the next
  verse, and stop changing the verse when the full window is clicked.
- **Default font style Regular**: the default `QuoteStyle` becomes `Normal` (Regular) instead of `Italic`.

## Capabilities

### New Capabilities
<!-- None; this refines the existing skin-settings capability. -->

### Modified Capabilities
- `skin-settings`: Adds an editable reference label, a border-opacity control, a show/hide toggle for the
  settings icon, and a dedicated change-verse control (with full-window click no longer changing the
  verse); improves checkbox/label alignment; and changes the default font style to Regular.

## Impact

- `Skins/AlQuranQuote/@Resources/Variables.inc`: new tunables (`ReferenceLabel`, `PanelBorderRGB` +
  `PanelBorderOpacity`, `SettingsIconHidden`, `VerseKey`), changed default `QuoteStyle=Normal`, and border
  bounds.
- `Skins/AlQuranQuote/AlQuranQuote.ini`: reference composed from `#ReferenceLabel# #VerseKey#`, border
  stroke split into RGB + opacity, the settings icon `Hidden` bound to `SettingsIconHidden`, a new
  next-verse control, and removal of the full-window click-to-change action.
- `Skins/AlQuranQuote/@Resources/Scripts/RandomAyah.lua` and `Verse.lua`: store the verse key in a
  variable (extract it for offline verses) so the reference recomposes live when the label changes.
- `Skins/AlQuranQuote/Settings/Settings.ini` and `SettingsTheme.inc`: new controls (reference label input,
  border-opacity slider + manual entry, show-icon checkbox), checkbox/label alignment, and layout growth.
- `Skins/AlQuranQuote/@Resources/Scripts/Settings.lua`: setters for the reference label, border opacity,
  and icon visibility; updated `defaults` (style Regular, new keys).
- `CLAUDE.md` and `CHANGELOG.md`: document the new settings and the default change.
