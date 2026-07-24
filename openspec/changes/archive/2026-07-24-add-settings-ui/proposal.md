## Why

Today the only way to restyle the skin is to hand-edit `@Resources/Variables.inc` and refresh, which
means opening a text file, knowing the RGBA/variable names, and reloading manually. That is a poor fit
for a desktop widget that users are expected to drop in and personalize. A small in-skin settings panel
lets a user change how the skin looks and how often verses rotate without ever touching a config file.

## What Changes

- Add a settings panel (a companion skin loaded from the main panel) that reads the current values from
  `Variables.inc` and lets the user change them live.
- Editable settings: font family, font size, font style (Bold / Regular / Italic), background opacity,
  background color, font color, and quote change duration (rotation interval).
- Persist every change back to `Variables.inc` with `!WriteKeyValue` and refresh the main skin so the
  change is visible immediately and survives a Rainmeter restart.
- Add a way to open the settings panel from the main skin (a small gear/settings affordance or a
  right-click context menu entry) and a way to close it.
- Introduce the new tunable variables the settings panel drives (for example a font-style variable and a
  separate background opacity value split out from the panel color) in `Variables.inc`.

## Capabilities

### New Capabilities
- `skin-settings`: An in-skin settings panel that lets the user view and change the skin's appearance
  (font family, size, style, font color, background color, background opacity) and the quote rotation
  duration, persisting each change to `Variables.inc` and applying it to the running skin.

### Modified Capabilities
<!-- No existing specs to modify (openspec/specs/ is empty). -->

## Impact

- `Skins/AlQuranQuote/@Resources/Variables.inc`: new/renamed tunables (font style, background opacity)
  that both the main skin and the settings panel read and write.
- `Skins/AlQuranQuote/AlQuranQuote.ini`: a control to open the settings panel; meters may reference the
  new style/opacity variables.
- New file(s) under `Skins/AlQuranQuote/` for the settings panel (its own `.ini` and any helper Lua),
  wired through `RMSKIN.ini` packaging.
- `RMSKIN.ini` / `.rmskin` package: the new settings skin must ship in the release bundle.
- No change to the verse-fetching data flow (WebParser + Lua) or to the quran.com API usage.
