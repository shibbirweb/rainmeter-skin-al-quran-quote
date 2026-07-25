-- Settings.lua : backs the Al-Quran Quote settings panel.
-- Runs in the settings skin (the AlQuranQuote\Settings child config). On open it seeds the panel's own
-- working variables from the parent config's current values. On every change it:
--   1. writes the value to the parent @Resources\Variables.inc (so it persists), and
--   2. applies it to the running MAIN skin (via !SetVariable, without a refresh, so the verse does not
--      refetch), then repaints the panel's previews in place.
-- The settings panel itself is never refreshed, so editing the skin never disturbs the panel.
-- Rotation changes (RotateEvery/AutoChange) also apply live via !SetVariable: [MeasureRotateTick] reads
-- them dynamically, so toggling rotation or changing the duration never refetches the verse. Only Reset
-- refreshes the main skin (which does refetch a verse).

local mainConfigName = 'AlQuranQuote'

-- Authoritative live state kept in Lua, so we never read back a variable we just set with a queued bang.
local fontColor = { red = 240, green = 240, blue = 240, alpha = 255 }
local refColor = { red = 205, green = 205, blue = 205, alpha = 200 }
local backgroundColor = { red = 18, green = 22, blue = 28 }
local fontSize = 13
local refFontSize = 10
local backgroundOpacity = 205
local borderOpacity = 25
local autoChange = 1
local rotateEvery = 1800

-- Canonical defaults for Reset. Mirrors the initial values in the skin's Variables.inc.
local defaults = {
	QuoteFont = 'Georgia',
	QuoteSize = 13,
	QuoteStyle = 'Normal',
	QuoteColor = '240,240,240,255',
	RefFont = 'Segoe UI',
	RefSize = 10,
	RefStyle = 'Normal',
	RefColor = '205,205,205,200',
	PanelColorRGB = '18,22,28',
	PanelOpacity = 205,
	PanelBorderRGB = '255,255,255',
	PanelBorderOpacity = 25,
	ReferenceLabel = 'Al Quran',
	SettingsIconHidden = 0,
	NextIconHidden = 0,
	RotateEvery = 1800,
	AutoChange = 1,
	WidthAuto = 1,
	FixedWidth = 340,
	HeightAuto = 1,
	FixedHeight = 160,
	PanelWidth = 340,
	ShowReferenceLabel = 1,
	ShowVerseNumber = 1,
	CustomVerseEnabled = 0,
	CustomText = '',
	SuraNumber = '',
	VerseNumberManual = '',
	OnlineFetchEnabled = 1,
}

function Initialize()
	loadSettings()
end

function Update()
	return 1
end

-- Full path to the parent config's Variables.inc (ROOTCONFIGPATH points at the main skin folder).
local function variablesFilePath()
	return SKIN:GetVariable('ROOTCONFIGPATH') .. '@Resources\\Variables.inc'
end

-- Split "12,34,56[,78]" into a list of numbers.
local function splitNumbers(text)
	local numbers = {}
	if text == nil then
		return numbers
	end
	for token in string.gmatch(text, '([^,]+)') do
		numbers[#numbers + 1] = tonumber(token)
	end
	return numbers
end

-- Round to the nearest integer and clamp to [minimum, maximum].
local function clampRound(value, minimum, maximum)
	local number = tonumber(value)
	if number == nil then
		return minimum
	end
	number = math.floor(number + 0.5)
	if number < minimum then
		number = minimum
	end
	if number > maximum then
		number = maximum
	end
	return number
end

local function readNumber(variableName)
	return tonumber(SKIN:GetVariable(variableName))
end

-- Re-evaluate the panel's meters so previews and labels reflect the working variables. No config refresh.
local function updatePanel()
	SKIN:Bang('!UpdateMeter', '*')
	SKIN:Bang('!Redraw')
end

-- Write one key to the parent Variables.inc (persist only).
local function persist(key, value)
	SKIN:Bang('!WriteKeyValue', 'Variables', key, value, variablesFilePath())
end

-- Persist a value and apply it live to the main skin without refetching a verse.
local function applyAppearance(key, value)
	persist(key, value)
	SKIN:Bang('!SetVariable', key, value, mainConfigName)
	SKIN:Bang('!UpdateMeter', '*', mainConfigName)
	SKIN:Bang('!Redraw', mainConfigName)
end

-- Persist a reference/custom value and ask the main skin to recompose its display (label, verse key and
-- custom verse are composed in the main skin's Lua). refreshDisplay recomposes without refetching.
local function applyMainRefresh(key, value)
	persist(key, value)
	SKIN:Bang('!SetVariable', key, value, mainConfigName)
	SKIN:Bang('!CommandMeasure', 'MeasureRandom', 'refreshDisplay()', mainConfigName)
end

-- Normalize a manual number field: keep it empty (nullable) or return the integer as text.
local function cleanNumberOrEmpty(value)
	if value == nil then
		return ''
	end
	local text = tostring(value)
	if text == '' then
		return ''
	end
	local number = tonumber(text)
	if number == nil then
		return ''
	end
	return tostring(math.floor(number))
end

-- ---- Color helpers ----

local function applyFontColor()
	SKIN:Bang('!SetVariable', 'FontColorR', fontColor.red)
	SKIN:Bang('!SetVariable', 'FontColorG', fontColor.green)
	SKIN:Bang('!SetVariable', 'FontColorB', fontColor.blue)
	SKIN:Bang('!SetVariable', 'FontColorA', fontColor.alpha)
	local composed = fontColor.red .. ',' .. fontColor.green .. ',' .. fontColor.blue .. ',' .. fontColor.alpha
	applyAppearance('QuoteColor', composed)
	updatePanel()
end

local function applyRefColor()
	SKIN:Bang('!SetVariable', 'RefColorR', refColor.red)
	SKIN:Bang('!SetVariable', 'RefColorG', refColor.green)
	SKIN:Bang('!SetVariable', 'RefColorB', refColor.blue)
	SKIN:Bang('!SetVariable', 'RefColorA', refColor.alpha)
	local composed = refColor.red .. ',' .. refColor.green .. ',' .. refColor.blue .. ',' .. refColor.alpha
	applyAppearance('RefColor', composed)
	updatePanel()
end

local function applyBackgroundColor()
	SKIN:Bang('!SetVariable', 'BgColorR', backgroundColor.red)
	SKIN:Bang('!SetVariable', 'BgColorG', backgroundColor.green)
	SKIN:Bang('!SetVariable', 'BgColorB', backgroundColor.blue)
	local composed = backgroundColor.red .. ',' .. backgroundColor.green .. ',' .. backgroundColor.blue
	applyAppearance('PanelColorRGB', composed)
	updatePanel()
end

-- Color sliders report position as a percentage (0-100); map it to a 0-255 channel value.
local function channelFromPercent(percent)
	return clampRound(tonumber(percent) / 100 * 255, 0, 255)
end

-- Set which font-style button is highlighted as active.
local function highlightStyle(styleKeyword)
	local inactive = SKIN:GetVariable('SettingsInactiveColor')
	local active = SKIN:GetVariable('SettingsActiveColor')
	local boldColor = inactive
	local regularColor = inactive
	local italicColor = inactive
	if styleKeyword == 'Bold' then
		boldColor = active
	elseif styleKeyword == 'Normal' then
		regularColor = active
	elseif styleKeyword == 'Italic' then
		italicColor = active
	end
	SKIN:Bang('!SetVariable', 'BoldColor', boldColor)
	SKIN:Bang('!SetVariable', 'RegularColor', regularColor)
	SKIN:Bang('!SetVariable', 'ItalicColor', italicColor)
end

-- Set which reference-style button is highlighted as active.
local function highlightRefStyle(styleKeyword)
	local inactive = SKIN:GetVariable('SettingsInactiveColor')
	local active = SKIN:GetVariable('SettingsActiveColor')
	local boldColor = inactive
	local regularColor = inactive
	local italicColor = inactive
	if styleKeyword == 'Bold' then
		boldColor = active
	elseif styleKeyword == 'Normal' then
		regularColor = active
	elseif styleKeyword == 'Italic' then
		italicColor = active
	end
	SKIN:Bang('!SetVariable', 'RefBoldColor', boldColor)
	SKIN:Bang('!SetVariable', 'RefRegularColor', regularColor)
	SKIN:Bang('!SetVariable', 'RefItalicColor', italicColor)
end

-- Color the active tab label and dim the others.
local function highlightTab(tabNumber)
	local inactive = SKIN:GetVariable('SettingsInactiveColor')
	local active = SKIN:GetVariable('SettingsActiveColor')
	local color1 = inactive
	local color2 = inactive
	local color3 = inactive
	if tabNumber == 1 then
		color1 = active
	elseif tabNumber == 2 then
		color2 = active
	else
		color3 = active
	end
	SKIN:Bang('!SetVariable', 'Tab1Color', color1)
	SKIN:Bang('!SetVariable', 'Tab2Color', color2)
	SKIN:Bang('!SetVariable', 'Tab3Color', color3)
end

-- Show one tab's meters and hide the others. The font-list overlay and the reveal-on-uncheck width/height
-- inputs are hidden here too (they are not in a Tab group) so they never show on the wrong tab; on the
-- Panel tab the width/height inputs reappear only when their "auto" box is unchecked. Global so the tab
-- buttons in Settings.ini can call it.
function setTab(tabNumber)
	SKIN:Bang('!SetVariable', 'ActiveTab', tabNumber)
	SKIN:Bang('!HideMeterGroup', 'Tab1')
	SKIN:Bang('!HideMeterGroup', 'Tab2')
	SKIN:Bang('!HideMeterGroup', 'Tab3')
	SKIN:Bang('!HideMeterGroup', 'FontList')
	SKIN:Bang('!SetVariable', 'FontListVisible', 0)
	SKIN:Bang('!HideMeterGroup', 'WidthInput')
	SKIN:Bang('!HideMeterGroup', 'HeightInput')
	if tabNumber == 1 then
		SKIN:Bang('!ShowMeterGroup', 'Tab1')
	elseif tabNumber == 2 then
		SKIN:Bang('!ShowMeterGroup', 'Tab2')
		if tonumber(SKIN:GetVariable('WidthAuto')) == 0 then
			SKIN:Bang('!ShowMeterGroup', 'WidthInput')
		end
		if tonumber(SKIN:GetVariable('HeightAuto')) == 0 then
			SKIN:Bang('!ShowMeterGroup', 'HeightInput')
		end
	else
		SKIN:Bang('!ShowMeterGroup', 'Tab3')
	end
	highlightTab(tabNumber)
	SKIN:Bang('!Redraw')
end

-- ---- Size / rotation apply helpers ----

-- Resolve the effective panel width (auto -> default; fixed -> clamped) and apply it to the main skin.
local function resolveAndApplyWidth(widthAuto, fixedWidth)
	local resolved
	if widthAuto == 1 then
		resolved = readNumber('DefaultPanelWidth')
	else
		resolved = clampRound(fixedWidth, readNumber('MinFixedWidth'), readNumber('MaxFixedWidth'))
	end
	applyAppearance('PanelWidth', resolved)
end

-- Apply height mode + fixed height to the main skin (the shape formula selects the branch).
local function applyHeight(heightAuto, fixedHeight)
	persist('HeightAuto', heightAuto)
	persist('FixedHeight', fixedHeight)
	SKIN:Bang('!SetVariable', 'HeightAuto', heightAuto, mainConfigName)
	SKIN:Bang('!SetVariable', 'FixedHeight', fixedHeight, mainConfigName)
	SKIN:Bang('!UpdateMeter', '*', mainConfigName)
	SKIN:Bang('!Redraw', mainConfigName)
end

-- Apply rotation changes (auto on/off and duration) to the main skin WITHOUT a refresh, so the displayed
-- verse is never refetched. [MeasureRotateTick] in the main skin reads AutoChange and RotateEvery with
-- DynamicVariables=1, so setting them live takes effect on the next tick.
local function applyRotation()
	persist('AutoChange', autoChange)
	persist('RotateEvery', rotateEvery)
	SKIN:Bang('!SetVariable', 'AutoChange', autoChange, mainConfigName)
	SKIN:Bang('!SetVariable', 'RotateEvery', rotateEvery, mainConfigName)
end

-- ---- Seeding (shared by load and reset) ----

-- Push a complete settings state into the panel's working variables and reveal/hide dependent controls.
local function seedWorkingState(state)
	fontColor.red = state.fontColor.red
	fontColor.green = state.fontColor.green
	fontColor.blue = state.fontColor.blue
	fontColor.alpha = state.fontColor.alpha
	refColor.red = state.refColor.red
	refColor.green = state.refColor.green
	refColor.blue = state.refColor.blue
	refColor.alpha = state.refColor.alpha
	backgroundColor.red = state.bgColor.red
	backgroundColor.green = state.bgColor.green
	backgroundColor.blue = state.bgColor.blue
	fontSize = state.fontSizeValue
	refFontSize = state.refFontSizeValue
	backgroundOpacity = state.opacity
	borderOpacity = state.borderOpacity
	autoChange = state.autoChangeValue
	rotateEvery = state.duration

	SKIN:Bang('!SetVariable', 'WorkFontFamily', state.fontFamily)
	SKIN:Bang('!SetVariable', 'WorkFontSize', fontSize)
	SKIN:Bang('!SetVariable', 'WorkStyle', state.style)
	SKIN:Bang('!SetVariable', 'WorkRefFontFamily', state.refFontFamily)
	SKIN:Bang('!SetVariable', 'WorkRefFontSize', refFontSize)
	SKIN:Bang('!SetVariable', 'WorkRefStyle', state.refStyle)
	SKIN:Bang('!SetVariable', 'RefColorR', refColor.red)
	SKIN:Bang('!SetVariable', 'RefColorG', refColor.green)
	SKIN:Bang('!SetVariable', 'RefColorB', refColor.blue)
	SKIN:Bang('!SetVariable', 'RefColorA', refColor.alpha)
	SKIN:Bang('!SetVariable', 'WorkDuration', rotateEvery)
	SKIN:Bang('!SetVariable', 'WorkOpacity', backgroundOpacity)
	SKIN:Bang('!SetVariable', 'WorkBorderOpacity', borderOpacity)
	SKIN:Bang('!SetVariable', 'WorkReferenceLabel', state.referenceLabel)
	SKIN:Bang('!SetVariable', 'SettingsIconHidden', state.iconHidden)
	SKIN:Bang('!SetVariable', 'NextIconHidden', state.nextIconHidden)
	SKIN:Bang('!SetVariable', 'FontColorR', fontColor.red)
	SKIN:Bang('!SetVariable', 'FontColorG', fontColor.green)
	SKIN:Bang('!SetVariable', 'FontColorB', fontColor.blue)
	SKIN:Bang('!SetVariable', 'FontColorA', fontColor.alpha)
	SKIN:Bang('!SetVariable', 'BgColorR', backgroundColor.red)
	SKIN:Bang('!SetVariable', 'BgColorG', backgroundColor.green)
	SKIN:Bang('!SetVariable', 'BgColorB', backgroundColor.blue)
	SKIN:Bang('!SetVariable', 'WidthAuto', state.widthAuto)
	SKIN:Bang('!SetVariable', 'FixedWidth', state.fixedWidth)
	SKIN:Bang('!SetVariable', 'HeightAuto', state.heightAuto)
	SKIN:Bang('!SetVariable', 'FixedHeight', state.fixedHeight)
	SKIN:Bang('!SetVariable', 'AutoChange', state.autoChangeValue)
	SKIN:Bang('!SetVariable', 'ShowReferenceLabel', state.showReferenceLabel)
	SKIN:Bang('!SetVariable', 'ShowVerseNumber', state.showVerseNumber)
	SKIN:Bang('!SetVariable', 'CustomVerseEnabled', state.customVerseEnabled)
	SKIN:Bang('!SetVariable', 'OnlineFetchEnabled', state.onlineFetchEnabled)
	SKIN:Bang('!SetVariable', 'WorkCustomText', state.customText)
	SKIN:Bang('!SetVariable', 'WorkSuraNumber', state.suraNumber)
	SKIN:Bang('!SetVariable', 'WorkVerseNumber', state.verseNumber)

	highlightStyle(state.style)
	highlightRefStyle(state.refStyle)

	SKIN:Bang('!HideMeterGroup', 'FontList')
	SKIN:Bang('!SetVariable', 'FontListVisible', 0)
	if state.widthAuto == 1 then
		SKIN:Bang('!HideMeterGroup', 'WidthInput')
	else
		SKIN:Bang('!ShowMeterGroup', 'WidthInput')
	end
	if state.heightAuto == 1 then
		SKIN:Bang('!HideMeterGroup', 'HeightInput')
	else
		SKIN:Bang('!ShowMeterGroup', 'HeightInput')
	end

	updatePanel()
end

-- Seed the panel from the parent config's current values (called on open).
function loadSettings()
	local fontColorParts = splitNumbers(SKIN:GetVariable('QuoteColor'))
	local refColorParts = splitNumbers(SKIN:GetVariable('RefColor'))
	local backgroundColorParts = splitNumbers(SKIN:GetVariable('PanelColorRGB'))
	seedWorkingState({
		fontFamily = SKIN:GetVariable('QuoteFont'),
		fontSizeValue = clampRound(readNumber('QuoteSize'), readNumber('MinQuoteSize'), readNumber('MaxQuoteSize')),
		style = SKIN:GetVariable('QuoteStyle'),
		refFontFamily = SKIN:GetVariable('RefFont'),
		refFontSizeValue = clampRound(readNumber('RefSize'), readNumber('MinQuoteSize'), readNumber('MaxQuoteSize')),
		refStyle = SKIN:GetVariable('RefStyle'),
		refColor = {
			red = refColorParts[1] or 205,
			green = refColorParts[2] or 205,
			blue = refColorParts[3] or 205,
			alpha = refColorParts[4] or 200,
		},
		duration = readNumber('RotateEvery'),
		opacity = clampRound(readNumber('PanelOpacity'), readNumber('MinPanelOpacity'), readNumber('MaxPanelOpacity')),
		borderOpacity = clampRound(readNumber('PanelBorderOpacity'), readNumber('MinPanelOpacity'), readNumber('MaxPanelOpacity')),
		referenceLabel = SKIN:GetVariable('ReferenceLabel'),
		iconHidden = tonumber(SKIN:GetVariable('SettingsIconHidden')) or 0,
		nextIconHidden = tonumber(SKIN:GetVariable('NextIconHidden')) or 0,
		fontColor = {
			red = fontColorParts[1] or 240,
			green = fontColorParts[2] or 240,
			blue = fontColorParts[3] or 240,
			alpha = fontColorParts[4] or 255,
		},
		bgColor = {
			red = backgroundColorParts[1] or 18,
			green = backgroundColorParts[2] or 22,
			blue = backgroundColorParts[3] or 28,
		},
		widthAuto = tonumber(SKIN:GetVariable('WidthAuto')) or 1,
		fixedWidth = readNumber('FixedWidth') or 340,
		heightAuto = tonumber(SKIN:GetVariable('HeightAuto')) or 1,
		fixedHeight = readNumber('FixedHeight') or 160,
		autoChangeValue = tonumber(SKIN:GetVariable('AutoChange')) or 1,
		showReferenceLabel = tonumber(SKIN:GetVariable('ShowReferenceLabel')) or 1,
		showVerseNumber = tonumber(SKIN:GetVariable('ShowVerseNumber')) or 1,
		customVerseEnabled = tonumber(SKIN:GetVariable('CustomVerseEnabled')) or 0,
		onlineFetchEnabled = tonumber(SKIN:GetVariable('OnlineFetchEnabled')) or 1,
		customText = SKIN:GetVariable('CustomText'),
		suraNumber = SKIN:GetVariable('SuraNumber'),
		verseNumber = SKIN:GetVariable('VerseNumberManual'),
	})
	setTab(1)
end

-- ---- Font family (list + manual) ----

-- The curated font list is shared by the Quote (left column) and Reference (right column) family rows.
-- target is 'quote' or 'ref'; it decides which font a pick applies to and which column the overlay opens
-- under. Clicking the same row again closes it.
function toggleFontList(target)
	local visible = tonumber(SKIN:GetVariable('FontListVisible'))
	local currentTarget = SKIN:GetVariable('FontListTarget')
	if visible == 1 and currentTarget == target then
		SKIN:Bang('!HideMeterGroup', 'FontList')
		SKIN:Bang('!SetVariable', 'FontListVisible', 0)
	else
		SKIN:Bang('!SetVariable', 'FontListTarget', target)
		if target == 'ref' then
			SKIN:Bang('!SetVariable', 'FontListX', SKIN:GetVariable('Col2X'))
		else
			SKIN:Bang('!SetVariable', 'FontListX', SKIN:GetVariable('Pad'))
		end
		SKIN:Bang('!ShowMeterGroup', 'FontList')
		SKIN:Bang('!SetVariable', 'FontListVisible', 1)
	end
	SKIN:Bang('!Redraw')
end

-- A font list item was clicked; apply it to whichever family row opened the list.
function setFont(fontName)
	if SKIN:GetVariable('FontListTarget') == 'ref' then
		setRefFont(fontName)
	else
		setQuoteFont(fontName)
	end
end

function setQuoteFont(fontName)
	SKIN:Bang('!SetVariable', 'WorkFontFamily', fontName)
	SKIN:Bang('!HideMeterGroup', 'FontList')
	SKIN:Bang('!SetVariable', 'FontListVisible', 0)
	applyAppearance('QuoteFont', fontName)
	updatePanel()
end

function setRefFont(fontName)
	SKIN:Bang('!SetVariable', 'WorkRefFontFamily', fontName)
	SKIN:Bang('!HideMeterGroup', 'FontList')
	SKIN:Bang('!SetVariable', 'FontListVisible', 0)
	applyAppearance('RefFont', fontName)
	updatePanel()
end

-- ---- Font size (slider) ----

function setFontSizePercent(percent)
	local minimum = readNumber('MinQuoteSize')
	local maximum = readNumber('MaxQuoteSize')
	fontSize = clampRound(minimum + (maximum - minimum) * tonumber(percent) / 100, minimum, maximum)
	SKIN:Bang('!SetVariable', 'WorkFontSize', fontSize)
	applyAppearance('QuoteSize', fontSize)
	updatePanel()
end

function nudgeFontSize(step)
	local minimum = readNumber('MinQuoteSize')
	local maximum = readNumber('MaxQuoteSize')
	fontSize = clampRound(fontSize + step, minimum, maximum)
	SKIN:Bang('!SetVariable', 'WorkFontSize', fontSize)
	applyAppearance('QuoteSize', fontSize)
	updatePanel()
end

-- ---- Font style ----

function setStyle(styleKeyword)
	SKIN:Bang('!SetVariable', 'WorkStyle', styleKeyword)
	highlightStyle(styleKeyword)
	applyAppearance('QuoteStyle', styleKeyword)
	updatePanel()
end

-- ---- Font color channels (percent is 0-100 from a slider; step is signed from the scroll wheel) ----

function setFontColorChannel(component, percent)
	local value = channelFromPercent(percent)
	if component == 'r' then
		fontColor.red = value
	elseif component == 'g' then
		fontColor.green = value
	elseif component == 'b' then
		fontColor.blue = value
	elseif component == 'a' then
		fontColor.alpha = value
	end
	applyFontColor()
end

function nudgeFontColorChannel(component, step)
	if component == 'r' then
		fontColor.red = clampRound(fontColor.red + step, 0, 255)
	elseif component == 'g' then
		fontColor.green = clampRound(fontColor.green + step, 0, 255)
	elseif component == 'b' then
		fontColor.blue = clampRound(fontColor.blue + step, 0, 255)
	elseif component == 'a' then
		fontColor.alpha = clampRound(fontColor.alpha + step, 0, 255)
	end
	applyFontColor()
end

-- Manual font color entry: "R,G,B" or "R,G,B,A". Alpha is kept unchanged if not supplied.
function setFontColorManual(text)
	local parts = splitNumbers(text)
	if #parts < 3 then
		return
	end
	fontColor.red = clampRound(parts[1], 0, 255)
	fontColor.green = clampRound(parts[2], 0, 255)
	fontColor.blue = clampRound(parts[3], 0, 255)
	if parts[4] ~= nil then
		fontColor.alpha = clampRound(parts[4], 0, 255)
	end
	applyFontColor()
end

-- ---- Reference font: size (slider), style (buttons), color (sliders + manual). Mirrors the quote's. ----

function setRefFontSizePercent(percent)
	local minimum = readNumber('MinQuoteSize')
	local maximum = readNumber('MaxQuoteSize')
	refFontSize = clampRound(minimum + (maximum - minimum) * tonumber(percent) / 100, minimum, maximum)
	SKIN:Bang('!SetVariable', 'WorkRefFontSize', refFontSize)
	applyAppearance('RefSize', refFontSize)
	updatePanel()
end

function nudgeRefFontSize(step)
	local minimum = readNumber('MinQuoteSize')
	local maximum = readNumber('MaxQuoteSize')
	refFontSize = clampRound(refFontSize + step, minimum, maximum)
	SKIN:Bang('!SetVariable', 'WorkRefFontSize', refFontSize)
	applyAppearance('RefSize', refFontSize)
	updatePanel()
end

function setRefStyle(styleKeyword)
	SKIN:Bang('!SetVariable', 'WorkRefStyle', styleKeyword)
	highlightRefStyle(styleKeyword)
	applyAppearance('RefStyle', styleKeyword)
	updatePanel()
end

function setRefColorChannel(component, percent)
	local value = channelFromPercent(percent)
	if component == 'r' then
		refColor.red = value
	elseif component == 'g' then
		refColor.green = value
	elseif component == 'b' then
		refColor.blue = value
	elseif component == 'a' then
		refColor.alpha = value
	end
	applyRefColor()
end

function nudgeRefColorChannel(component, step)
	if component == 'r' then
		refColor.red = clampRound(refColor.red + step, 0, 255)
	elseif component == 'g' then
		refColor.green = clampRound(refColor.green + step, 0, 255)
	elseif component == 'b' then
		refColor.blue = clampRound(refColor.blue + step, 0, 255)
	elseif component == 'a' then
		refColor.alpha = clampRound(refColor.alpha + step, 0, 255)
	end
	applyRefColor()
end

function setRefColorManual(text)
	local parts = splitNumbers(text)
	if #parts < 3 then
		return
	end
	refColor.red = clampRound(parts[1], 0, 255)
	refColor.green = clampRound(parts[2], 0, 255)
	refColor.blue = clampRound(parts[3], 0, 255)
	if parts[4] ~= nil then
		refColor.alpha = clampRound(parts[4], 0, 255)
	end
	applyRefColor()
end

-- ---- Background color channels (sliders) + manual R,G,B entry ----

function setBackgroundColorChannel(component, percent)
	local value = channelFromPercent(percent)
	if component == 'r' then
		backgroundColor.red = value
	elseif component == 'g' then
		backgroundColor.green = value
	elseif component == 'b' then
		backgroundColor.blue = value
	end
	applyBackgroundColor()
end

function nudgeBackgroundColorChannel(component, step)
	if component == 'r' then
		backgroundColor.red = clampRound(backgroundColor.red + step, 0, 255)
	elseif component == 'g' then
		backgroundColor.green = clampRound(backgroundColor.green + step, 0, 255)
	elseif component == 'b' then
		backgroundColor.blue = clampRound(backgroundColor.blue + step, 0, 255)
	end
	applyBackgroundColor()
end

function setBackgroundColorManual(text)
	local parts = splitNumbers(text)
	if #parts < 3 then
		return
	end
	backgroundColor.red = clampRound(parts[1], 0, 255)
	backgroundColor.green = clampRound(parts[2], 0, 255)
	backgroundColor.blue = clampRound(parts[3], 0, 255)
	applyBackgroundColor()
end

-- ---- Background opacity (range) + manual entry ----

function setOpacityPercent(percent)
	local minimum = readNumber('MinPanelOpacity')
	local maximum = readNumber('MaxPanelOpacity')
	backgroundOpacity = clampRound(minimum + (maximum - minimum) * tonumber(percent) / 100, minimum, maximum)
	SKIN:Bang('!SetVariable', 'WorkOpacity', backgroundOpacity)
	applyAppearance('PanelOpacity', backgroundOpacity)
	updatePanel()
end

function nudgeOpacity(step)
	local minimum = readNumber('MinPanelOpacity')
	local maximum = readNumber('MaxPanelOpacity')
	backgroundOpacity = clampRound(backgroundOpacity + step, minimum, maximum)
	SKIN:Bang('!SetVariable', 'WorkOpacity', backgroundOpacity)
	applyAppearance('PanelOpacity', backgroundOpacity)
	updatePanel()
end

function setOpacityValue(value)
	local number = tonumber(value)
	if number == nil then
		return
	end
	backgroundOpacity = clampRound(number, readNumber('MinPanelOpacity'), readNumber('MaxPanelOpacity'))
	SKIN:Bang('!SetVariable', 'WorkOpacity', backgroundOpacity)
	applyAppearance('PanelOpacity', backgroundOpacity)
	updatePanel()
end

-- ---- Panel width (auto / fixed) ----

function toggleWidthAuto()
	local widthAuto = tonumber(SKIN:GetVariable('WidthAuto'))
	if widthAuto == 1 then
		widthAuto = 0
	else
		widthAuto = 1
	end
	SKIN:Bang('!SetVariable', 'WidthAuto', widthAuto)
	persist('WidthAuto', widthAuto)
	if widthAuto == 1 then
		SKIN:Bang('!HideMeterGroup', 'WidthInput')
	else
		SKIN:Bang('!ShowMeterGroup', 'WidthInput')
	end
	resolveAndApplyWidth(widthAuto, readNumber('FixedWidth'))
	updatePanel()
end

function setFixedWidth(value)
	local number = clampRound(value, readNumber('MinFixedWidth'), readNumber('MaxFixedWidth'))
	SKIN:Bang('!SetVariable', 'FixedWidth', number)
	persist('FixedWidth', number)
	resolveAndApplyWidth(tonumber(SKIN:GetVariable('WidthAuto')), number)
	updatePanel()
end

-- ---- Panel height (auto / fixed) ----

function toggleHeightAuto()
	local heightAuto = tonumber(SKIN:GetVariable('HeightAuto'))
	if heightAuto == 1 then
		heightAuto = 0
	else
		heightAuto = 1
	end
	SKIN:Bang('!SetVariable', 'HeightAuto', heightAuto)
	if heightAuto == 1 then
		SKIN:Bang('!HideMeterGroup', 'HeightInput')
	else
		SKIN:Bang('!ShowMeterGroup', 'HeightInput')
	end
	applyHeight(heightAuto, readNumber('FixedHeight'))
	updatePanel()
end

function setFixedHeight(value)
	local number = clampRound(value, readNumber('MinFixedHeight'), readNumber('MaxFixedHeight'))
	SKIN:Bang('!SetVariable', 'FixedHeight', number)
	applyHeight(tonumber(SKIN:GetVariable('HeightAuto')), number)
	updatePanel()
end

-- ---- Automatic rotation + duration ----

function toggleAutoChange()
	if autoChange == 1 then
		autoChange = 0
	else
		autoChange = 1
	end
	-- Update the panel's own checkbox variable, then apply the new rotation rate to the main skin.
	SKIN:Bang('!SetVariable', 'AutoChange', autoChange)
	applyRotation()
	updatePanel()
end

function setDuration(value)
	local number = tonumber(value)
	if number == nil then
		return
	end
	rotateEvery = clampRound(number, readNumber('MinRotateEvery'), readNumber('MaxRotateEvery'))
	SKIN:Bang('!SetVariable', 'WorkDuration', rotateEvery)
	applyRotation()
	updatePanel()
end

-- ---- Reference label ----

function setReferenceLabel(text)
	SKIN:Bang('!SetVariable', 'WorkReferenceLabel', text)
	applyMainRefresh('ReferenceLabel', text)
	updatePanel()
end

-- ---- Reference visibility toggles (apply to fetched and custom verses) ----

function toggleShowReferenceLabel()
	local show = tonumber(SKIN:GetVariable('ShowReferenceLabel'))
	if show == 1 then
		show = 0
	else
		show = 1
	end
	SKIN:Bang('!SetVariable', 'ShowReferenceLabel', show)
	applyMainRefresh('ShowReferenceLabel', show)
	updatePanel()
end

function toggleShowVerseNumber()
	local show = tonumber(SKIN:GetVariable('ShowVerseNumber'))
	if show == 1 then
		show = 0
	else
		show = 1
	end
	SKIN:Bang('!SetVariable', 'ShowVerseNumber', show)
	applyMainRefresh('ShowVerseNumber', show)
	updatePanel()
end

-- ---- Custom verse (text + manual sura/verse) ----

-- Toggle custom-verse mode. Turning it on shows the custom verse immediately; turning it off fetches a
-- fresh API verse (the tick and the next-verse control read CustomVerseEnabled dynamically).
function toggleCustomVerse()
	local enabled = tonumber(SKIN:GetVariable('CustomVerseEnabled'))
	if enabled == 1 then
		enabled = 0
	else
		enabled = 1
	end
	SKIN:Bang('!SetVariable', 'CustomVerseEnabled', enabled)
	persist('CustomVerseEnabled', enabled)
	SKIN:Bang('!SetVariable', 'CustomVerseEnabled', enabled, mainConfigName)
	if enabled == 1 then
		SKIN:Bang('!CommandMeasure', 'MeasureRandom', 'refreshDisplay()', mainConfigName)
	else
		SKIN:Bang('!CommandMeasure', 'MeasureQuran', 'Update', mainConfigName)
		SKIN:Bang('!UpdateMeasure', 'MeasureQuran', mainConfigName)
	end
	updatePanel()
end

-- Toggle online fetching. Applying it live via nextVerse() shows the right verse immediately: an online
-- download when turned on, or an offline verse when turned off.
function toggleOnlineFetch()
	local enabled = tonumber(SKIN:GetVariable('OnlineFetchEnabled'))
	if enabled == 1 then
		enabled = 0
	else
		enabled = 1
	end
	SKIN:Bang('!SetVariable', 'OnlineFetchEnabled', enabled)
	persist('OnlineFetchEnabled', enabled)
	SKIN:Bang('!SetVariable', 'OnlineFetchEnabled', enabled, mainConfigName)
	SKIN:Bang('!CommandMeasure', 'MeasureRandom', 'nextVerse()', mainConfigName)
	updatePanel()
end

-- The three inputs write their typed value to a working variable first (so an apostrophe cannot break the
-- command), then call these to read it back and apply. The number fields are nullable.
function commitCustomText()
	local text = SKIN:GetVariable('WorkCustomText')
	applyMainRefresh('CustomText', text)
	updatePanel()
end

function commitSuraNumber()
	local cleaned = cleanNumberOrEmpty(SKIN:GetVariable('WorkSuraNumber'))
	SKIN:Bang('!SetVariable', 'WorkSuraNumber', cleaned)
	applyMainRefresh('SuraNumber', cleaned)
	updatePanel()
end

function commitVerseNumber()
	local cleaned = cleanNumberOrEmpty(SKIN:GetVariable('WorkVerseNumber'))
	SKIN:Bang('!SetVariable', 'WorkVerseNumber', cleaned)
	applyMainRefresh('VerseNumberManual', cleaned)
	updatePanel()
end

-- ---- Border opacity (range + manual) ----

function setBorderOpacityPercent(percent)
	local minimum = readNumber('MinPanelOpacity')
	local maximum = readNumber('MaxPanelOpacity')
	borderOpacity = clampRound(minimum + (maximum - minimum) * tonumber(percent) / 100, minimum, maximum)
	SKIN:Bang('!SetVariable', 'WorkBorderOpacity', borderOpacity)
	applyAppearance('PanelBorderOpacity', borderOpacity)
	updatePanel()
end

function nudgeBorderOpacity(step)
	local minimum = readNumber('MinPanelOpacity')
	local maximum = readNumber('MaxPanelOpacity')
	borderOpacity = clampRound(borderOpacity + step, minimum, maximum)
	SKIN:Bang('!SetVariable', 'WorkBorderOpacity', borderOpacity)
	applyAppearance('PanelBorderOpacity', borderOpacity)
	updatePanel()
end

function setBorderOpacityValue(value)
	local number = tonumber(value)
	if number == nil then
		return
	end
	borderOpacity = clampRound(number, readNumber('MinPanelOpacity'), readNumber('MaxPanelOpacity'))
	SKIN:Bang('!SetVariable', 'WorkBorderOpacity', borderOpacity)
	applyAppearance('PanelBorderOpacity', borderOpacity)
	updatePanel()
end

-- ---- Settings icon visibility ----

function toggleShowIcon()
	local hidden = tonumber(SKIN:GetVariable('SettingsIconHidden'))
	if hidden == 1 then
		hidden = 0
	else
		hidden = 1
	end
	SKIN:Bang('!SetVariable', 'SettingsIconHidden', hidden)
	applyAppearance('SettingsIconHidden', hidden)
	updatePanel()
end

function toggleShowNextIcon()
	local hidden = tonumber(SKIN:GetVariable('NextIconHidden'))
	if hidden == 1 then
		hidden = 0
	else
		hidden = 1
	end
	SKIN:Bang('!SetVariable', 'NextIconHidden', hidden)
	applyAppearance('NextIconHidden', hidden)
	updatePanel()
end

-- ---- Reset ----

function resetSettings()
	for key, value in pairs(defaults) do
		persist(key, value)
	end
	-- Clear the persisted verse so Reset shows a fresh verse after the refresh (first-run path).
	SKIN:Bang('!WriteKeyValue', 'Variables', 'VersePersisted', 0, SKIN:GetVariable('ROOTCONFIGPATH') .. '@Resources\\LastVerse.inc')
	SKIN:Bang('!Refresh', mainConfigName)

	local fontColorParts = splitNumbers(defaults.QuoteColor)
	local refColorParts = splitNumbers(defaults.RefColor)
	local backgroundColorParts = splitNumbers(defaults.PanelColorRGB)
	seedWorkingState({
		fontFamily = defaults.QuoteFont,
		fontSizeValue = defaults.QuoteSize,
		style = defaults.QuoteStyle,
		refFontFamily = defaults.RefFont,
		refFontSizeValue = defaults.RefSize,
		refStyle = defaults.RefStyle,
		refColor = {
			red = refColorParts[1],
			green = refColorParts[2],
			blue = refColorParts[3],
			alpha = refColorParts[4],
		},
		duration = defaults.RotateEvery,
		opacity = defaults.PanelOpacity,
		borderOpacity = defaults.PanelBorderOpacity,
		referenceLabel = defaults.ReferenceLabel,
		iconHidden = defaults.SettingsIconHidden,
		nextIconHidden = defaults.NextIconHidden,
		fontColor = {
			red = fontColorParts[1],
			green = fontColorParts[2],
			blue = fontColorParts[3],
			alpha = fontColorParts[4],
		},
		bgColor = {
			red = backgroundColorParts[1],
			green = backgroundColorParts[2],
			blue = backgroundColorParts[3],
		},
		widthAuto = defaults.WidthAuto,
		fixedWidth = defaults.FixedWidth,
		heightAuto = defaults.HeightAuto,
		fixedHeight = defaults.FixedHeight,
		autoChangeValue = defaults.AutoChange,
		showReferenceLabel = defaults.ShowReferenceLabel,
		showVerseNumber = defaults.ShowVerseNumber,
		customVerseEnabled = defaults.CustomVerseEnabled,
		onlineFetchEnabled = defaults.OnlineFetchEnabled,
		customText = defaults.CustomText,
		suraNumber = defaults.SuraNumber,
		verseNumber = defaults.VerseNumberManual,
	})
	setTab(1)
end
