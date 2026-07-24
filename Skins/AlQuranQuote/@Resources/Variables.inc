[Variables]
; Al-Quran Quote - all tunables live here. Edit, then refresh the skin.

; ---- Content (set at runtime by the Lua script; leave as-is) ----
QuoteText=Loading verse...
RefText=

; ---- Rotation ----
; The skin updates once per second (see [Rainmeter] Update=1000), and WebParser re-downloads a fresh
; verse every RotateEvery updates. 1800 = 30 minutes. (Click the panel for the next verse anytime.)
; Editable from the settings panel (clamped to at least MinRotateEvery).
RotateEvery=1800
; AutoChange toggles automatic rotation on (1) or off (0). Rotation is driven by [MeasureRotateTick] in
; the main skin (a timer that forces a new download every RotateEvery seconds while AutoChange is 1), not
; by the WebParser's own download timer, so toggling it never refetches the current verse.
AutoChange=1

; ---- Layout ----
; PanelWidth is the resolved width the skin renders at. When width is "auto" the settings panel sets it to
; DefaultPanelWidth; when fixed, to the user's FixedWidth. Height is auto (grows to fit) unless HeightAuto
; is 0, then FixedHeight is used. IconGap is the space below the settings icon before the verse starts.
PanelWidth=340
DefaultPanelWidth=340
WidthAuto=1
FixedWidth=340
HeightAuto=1
FixedHeight=160
Pad=18
Radius=14
IconGap=6

; ---- Theme ----
; QuoteFont, QuoteSize, QuoteStyle, QuoteColor, PanelColorRGB and PanelOpacity are editable from the
; settings panel (gear icon on the main panel). RefFont/RefSize/RefColor/PanelBorder stay fixed.
QuoteFont=Georgia
RefFont=Segoe UI
QuoteSize=13
RefSize=10
; QuoteStyle is a Rainmeter StringStyle keyword: Bold, Normal (Regular), or Italic.
QuoteStyle=Italic
QuoteColor=240,240,240,255
RefColor=205,205,205,200
; Background color is split into RGB and opacity so each can be changed on its own. The panel fill is
; composed as PanelColorRGB,PanelOpacity (opacity is the alpha channel, 0-255).
PanelColorRGB=18,22,28
PanelOpacity=205
PanelBorder=255,255,255,25

; ---- Settings icon (opens the settings panel; drawn as vector shapes, no font glyph) ----
GearColor=205,205,205,140
GearIconWidth=14
GearIconHeight=14

; ---- Settings bounds ----
; Named limits the settings panel clamps numeric input to, so a bad value can never corrupt the skin.
MinQuoteSize=6
MaxQuoteSize=48
MinPanelOpacity=0
MaxPanelOpacity=255
; Rotation bounds, in seconds/updates (60 = one minute, 86400 = one day).
MinRotateEvery=60
MaxRotateEvery=86400
; Fixed width/height bounds, in pixels.
MinFixedWidth=160
MaxFixedWidth=1000
MinFixedHeight=80
MaxFixedHeight=1000
