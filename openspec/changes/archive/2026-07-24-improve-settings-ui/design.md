## Context

Change `add-settings-ui` added a settings panel (a child config, `AlQuranQuote\Settings`) driven by the
InputText plugin, `!WriteKeyValue`, and a small Lua helper. In use it has four problems, visible in the
user's screenshot:

1. The gear (main panel) and close (settings panel) use Unicode glyphs. The `.ini` was read as ANSI, so
   they render as mojibake (`âœ•`). Root cause: Rainmeter reads a `.ini` as ANSI unless it is UTF-16, or
   UTF-8 *with a BOM*; the files were written as UTF-8 without a BOM.
2. Long labels ("Background opacity", "Change every (sec)") overlap their values because the value column
   starts too close to the label column.
3. Every control is a raw text field. Users want a font list, a color picker, and a draggable opacity
   range.
4. Committing a change refreshes the settings panel itself, so the tool disturbs itself while open.

Constraints from CLAUDE.md still hold: minimal, structure/config split, descriptive names, no bundled
font/image binaries, no magic numbers, no nested ternaries, human-readable over clever.

## Goals / Non-Goals

**Goals:**
- Icons that always render (encoding-proof) with no bundled binary.
- A layout where labels never overlap controls.
- Font family chosen from a curated list; font and background color chosen with RGB(A) sliders and a live
  preview; background opacity set with a range control.
- The settings panel's own look is isolated from the values it edits, and committing a change never
  refreshes/redraws the panel.

**Non-Goals:**
- Dynamic enumeration of installed fonts (PowerShell/registry). Explicitly skipped per the user; the list
  is curated.
- A native OS color dialog (Rainmeter has none) or an HSV color wheel.
- True pixel-accurate click-and-drag tracking of slider handles (see Risks); the range is click-to-set
  plus scroll-to-nudge, which Rainmeter supports reliably.
- Restyling the reference line, or any change to the verse-fetching data flow.

## Decisions

### Decision: Vector Shape icons instead of font glyphs; BOM for any non-ASCII file

Draw the open and close controls with Shape meters (vector, no font dependency, encoding-proof):
- **Close** = two crossing `Line` shapes forming an X.
- **Open (settings)** = a "sliders" icon: three short horizontal `Line` shapes at different Y, each with a
  small `Ellipse` knob at a different X. It reads as "adjust settings" and previews the new slider UI, and
  is far simpler to draw than a toothed cog.

As a belt-and-suspenders rule, any `.ini` that still contains non-ASCII text will be saved as UTF-8 with a
BOM so Rainmeter never falls back to ANSI. Preferring Shape icons means the panels do not depend on that.

Alternative considered: keep glyphs but fix encoding only. Rejected as the sole fix because it is
invisible in code review and easy to regress on the next edit; vector icons remove the dependency.

### Decision: One setting per block (label above control) to end overlap

Replace the tight two-column rows with a vertical stack of blocks: a label line, then its control beneath
it, full panel width. This gives sliders, the font list, and the color preview the horizontal room they
need and removes any chance of label/value collision. Row and block metrics are named constants in the
settings-UI theme, not magic numbers.

### Decision: Curated font list as a click-to-select overlay

The font row shows the current family and, when clicked, toggles a small overlay list of curated fonts
(for example Georgia, Segoe UI, Arial, Calibri, Cambria, Times New Roman, Consolas, Verdana, Tahoma,
Trebuchet MS). The list is a Shape background plus one clickable String meter per font, shown/hidden with
a `FontListVisible` variable (meters `Hidden=(1 - #FontListVisible#)`, grouped). Clicking a name writes
`QuoteFont` and hides the list. The curated names live in the settings-UI theme file so the list is easy
to extend.

### Decision: Color picker = RGB(A) sliders + live preview, backed by working variables

The settings skin owns working variables for the live color state, separate from the persisted values:
- Font color: `FontColorR`, `FontColorG`, `FontColorB`, `FontColorA`.
- Background color: `BgColorR`, `BgColorG`, `BgColorB`.

On panel open, `Settings.lua` parses the current `QuoteColor` (`R,G,B,A`) and `PanelColorRGB` (`R,G,B`)
into these working variables. Each channel has a slider; a preview swatch is a Shape filled with
`#FontColorR#,#FontColorG#,#FontColorB#,#FontColorA#` (and similarly for background), so it updates the
instant a working variable changes. On a channel change, `Settings.lua` composes the working variables
back into the `R,G,B,A` / `R,G,B` string, writes it to `Variables.inc`, and refreshes the main skin only.
The swatch and slider fills update in place via `!UpdateMeter` + `!Redraw` on the settings skin (never a
full refresh).

### Decision: A single reusable slider component; opacity reuses it

A slider is a track (Shape), a fill (Shape sized to the value), and a handle (Shape). Interaction:
- **Click** anywhere on the track sets the value from the click position relative to the track, using
  Rainmeter's mouse-position action variable, clamped to the channel/opacity range.
- **Scroll wheel** over the track nudges the value by a named step (`MouseScrollUpAction` /
  `MouseScrollDownAction`).

The same component drives the four font-color channels, the three background-color channels, and the
background opacity range (0-255, from `MinPanelOpacity`/`MaxPanelOpacity`). Exact mouse-variable syntax
(for example `$MouseX$` vs a percentage form) is confirmed against the Rainmeter docs during
implementation; the value formula is `min + round((max - min) * position)`.

Alternative considered: keep numeric InputText for opacity. Rejected: the user asked for a range control.

### Decision: Isolate the settings-UI theme; commit applies to the main skin only

- Move the settings panel's own appearance (fonts, sizes, colors, panel background/opacity, slider colors,
  layout constants, curated font names) into a dedicated `Settings/@Resources/SettingsTheme.inc`, included
  by the settings skin via `@IncludeVariables`. The panel styles itself only from this file.
- The settings skin still reads the parent `@Resources\Variables.inc` via a second include
  (`@IncludeVariables2=#ROOTCONFIGPATH#@Resources\Variables.inc`) but only to seed working variables and
  show current selections, never to style itself.
- `Settings.lua` stops refreshing the settings config. Committing a change writes to `Variables.inc`,
  refreshes the main skin, and updates the panel's in-place display via working variables +
  `!UpdateMeter`/`!Redraw`. Because the panel reloads (its `Initialize` runs) each time it is toggled on,
  it always opens showing current values without ever refreshing itself mid-session.

This directly satisfies "the settings should not affect the settings UI": the panel's look comes from its
own theme, and editing values never rebuilds the panel.

### Decision: Font size becomes a slider; style stays buttons; duration stays typed

For layout consistency with the color/opacity sliders (and to avoid positioning an InputText box inside a
relatively laid-out panel), font size is a slider over `MinQuoteSize`-`MaxQuoteSize`. Font style stays as
three buttons, and change-every-duration stays a typed InputText (its range, up to a day in seconds, is
too wide for a linear slider). All three reflect their current value through settings-owned working
variables (`WorkFontSize`, `WorkStyle` via the active-button highlight, `WorkDuration`) updated on commit,
so the shown value stays correct in place without refreshing the panel.

## Risks / Trade-offs

- **No true drag tracking.** Rainmeter has no mouse-move event, so the range is click-to-set plus
  scroll-to-nudge. → This is reliable and still feels like a range; document it so users know to click or
  scroll rather than expecting to drag the handle. Drag can be revisited later if needed.
- **Curated font list can omit a user's preferred font.** → The list is easy to extend in
  `SettingsTheme.inc`; dynamic enumeration was deliberately declined by the user.
- **Live apply on every slider click/scroll writes to `Variables.inc` and refreshes the main skin.** →
  Writes happen once per click or per scroll notch (not continuously), which is acceptable; the preview
  updates in-panel without any file write.
- **Encoding regressions.** → Preferring Shape icons removes the font-glyph dependency; the BOM rule is a
  secondary guard, called out in CLAUDE.md.
- **This change overlaps `add-settings-ui`, which is not yet archived.** → It refines the same
  `skin-settings` capability. If `add-settings-ui` is archived first, reconcile the two deltas; otherwise
  treat this as the current source of truth for the panel.

## Migration Plan

1. Add `Settings/@Resources/SettingsTheme.inc` with the panel's own theme + layout + curated font list.
2. Rework `Settings.ini`: two includes, block layout, Shape close icon, font-list overlay, color sliders
   with preview, opacity range, and working/display variables.
3. Replace the main panel's gear glyph with a Shape sliders icon in `AlQuranQuote.ini`.
4. Extend `Settings.lua`: `loadColorComponents` (parse on open), `composeColor`/apply helpers, and change
   the apply path to refresh the main skin only.
5. Save any file containing non-ASCII as UTF-8 with BOM.
6. Update `CLAUDE.md` and `CHANGELOG.md`.
7. Rollback: revert these files; the persisted tunables in `Variables.inc` are unchanged in shape
   (`QuoteColor`, `PanelColorRGB`, `PanelOpacity`, `QuoteFont`, `QuoteSize`, `QuoteStyle`, `RotateEvery`).

## Open Questions

- Which exact fonts belong in the curated list? (A sensible default set is proposed above.)
- Should the font-color alpha and the background opacity both be exposed, or is per-color alpha enough?
  (Current design: font color has alpha; background uses the separate opacity range.)
- Is scroll-to-nudge + click-to-set an acceptable "range", or is click-and-drag required later?
