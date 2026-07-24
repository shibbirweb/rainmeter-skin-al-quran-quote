[Variables]
; Al-Quran Quote - all tunables live here. Edit, then refresh the skin.

; ---- Content (set at runtime by the Lua script; leave as-is) ----
QuoteText=Loading verse...
; VerseKey is the chapter:verse (for example 6:124), set at runtime. The reference is composed in the meter
; as "#ReferenceLabel# #VerseKey#", so changing the label updates the shown reference live.
VerseKey=
; The label shown before the verse key (editable from the settings panel).
ReferenceLabel=Al Quran

; ---- Rotation ----
; The skin updates once per second (see [Rainmeter] Update=1000), and WebParser re-downloads a fresh
; verse every RotateEvery updates. 1800 = 30 minutes. (Click the panel for the next verse anytime.)
; Editable from the settings panel (clamped to at least MinRotateEvery).
RotateEvery=1800
; AutoChange toggles automatic rotation on (1) or off (0). Rotation is driven by [MeasureRotateTick] in
; the main skin (a timer that forces a new download every RotateEvery seconds while AutoChange is 1), not
; by the WebParser's own download timer, so toggling it never refetches the current verse.
AutoChange=1
; A very large WebParser UpdateRate so the parent never auto-downloads on its own; rotation is driven by
; [MeasureRotateTick] and the next-verse icon forcing an Update instead. (About 31 years at one per second.)
WebParserIdleRate=1000000000

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
; Most of these are editable from the settings panel. RefFont/RefSize/RefColor stay fixed.
QuoteFont=Georgia
RefFont=Segoe UI
QuoteSize=13
RefSize=10
; QuoteStyle is a Rainmeter StringStyle keyword: Bold, Normal (Regular), or Italic. Default is Regular.
QuoteStyle=Normal
QuoteColor=240,240,240,255
RefColor=205,205,205,200
; Background color and border are each split into RGB and opacity so color and opacity change on their own.
; The panel fill is PanelColorRGB,PanelOpacity and the border is PanelBorderRGB,PanelBorderOpacity.
PanelColorRGB=18,22,28
PanelOpacity=205
PanelBorderRGB=255,255,255
PanelBorderOpacity=25

; ---- Settings icon (opens the settings panel; drawn as vector shapes, no font glyph) ----
GearColor=205,205,205,140
GearIconWidth=14
GearIconHeight=14
; SettingsIconHidden hides the icon on the quote window when 1 (reopen settings from Rainmeter's Manage).
SettingsIconHidden=0
; Next-verse control (small chevron by the reference that fetches the next verse).
NextIconWidth=12
NextIconHeight=14

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
