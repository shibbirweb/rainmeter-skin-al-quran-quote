[Variables]
; Al-Quran Quote - all tunables live here. Edit, then refresh the skin.

; ---- Content ----
; The displayed verse (QuoteText, VerseKey, RefText, RefUseLabel) is persisted in @Resources\LastVerse.inc,
; and the user-typed ReferenceLabel and CustomText live in @Resources\UserContent.inc (UTF-16, so Unicode
; survives). Both are included after this file. See those files and Verse.lua's applyVerse.
; ShowReferenceLabel / ShowVerseNumber toggle the two parts of the reference line (1 shows, 0 hides). They
; apply to both fetched verses and the custom verse. Editable from the settings panel.
ShowReferenceLabel=1
ShowVerseNumber=1

; ---- Custom verse (a user-provided verse shown instead of the fetched one) ----
; When CustomVerseEnabled is 1 the skin shows CustomText (in UserContent.inc) with the manual
; SuraNumber:VerseNumberManual as the reference, and does NOT fetch or rotate (the next-verse control is
; hidden). When 0, normal API verses show. SuraNumber and VerseNumberManual are nullable: if either is
; empty the reference shows no number (just the label, centered). All editable from the settings panel.
CustomVerseEnabled=0
SuraNumber=
VerseNumberManual=

; ---- Rotation ----
; The skin updates once per second (see [Rainmeter] Update=1000). [MeasureRotateTick] counts those
; updates and fetches the next verse every RotateEvery seconds. 1800 = 30 minutes. (Use the next-verse
; control for the next verse anytime.) Editable from the settings panel (clamped to at least MinRotateEvery).
RotateEvery=1800
; AutoChange toggles automatic rotation on (1) or off (0). [MeasureRotateTick] only fetches when it is 1.
; Both RotateEvery and AutoChange are read dynamically, so changing either takes effect with no refresh
; and never refetches the current verse.
AutoChange=1
; OnlineFetchEnabled toggles fetching from the quran.com API on (1) or off (0). When 0 the skin never
; hits the network: load, rotation, and the next-verse control all draw from the offline quotes.txt.
; Off by default (offline). Editable from the settings panel.
OnlineFetchEnabled=0
; [MeasureQuran] UpdateRate. It counts skin updates (one per second); the WebParser re-downloads on its own
; timer only when the counter reaches this value. Set effectively to "never" so downloads happen only on
; load and on demand ([MeasureRotateTick] rotation and the next-verse click, via CommandMeasure Update).
; Do NOT lower it: a smaller value would make the WebParser download on its own, ungated by AutoChange.
DownloadOnDemandRate=2000000000

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
; All of these are editable from the settings panel (Text tab: Quote on the left, Reference on the right).
QuoteFont=Georgia
RefFont=Segoe UI
QuoteSize=13
RefSize=10
; QuoteStyle/RefStyle are Rainmeter StringStyle keywords: Bold, Normal (Regular), or Italic. Default Regular.
QuoteStyle=Normal
RefStyle=Normal
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
; NextIconHidden hides the next-verse chevron on the quote window when 1 (change the verse from the
; settings Verse tab's "Change verse" button instead). Editable from the settings panel.
NextIconHidden=0

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
