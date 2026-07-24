-- RandomAyah.lua : entry points the skin calls.
--   Online()          show the verse WebParser just downloaded
--   Offline()         show a random verse from the bundled quotes file
--   nextVerse()       show the next verse from the active source (custom / online / offline)
--   refreshDisplay()  called by the settings panel after a reference/custom change (no refetch)
-- Helpers live in Verse.lua (applyVerse, refreshReference, composeReferenceText) and QuoteFile.lua
-- (readLines, parseLine). When CustomVerseEnabled is 1 the skin shows the user's custom verse instead of
-- fetching; Online/Offline route to it so a stray download never overwrites the custom verse.

function Initialize()
	local resourcesFolder = SKIN:GetVariable('@')
	dofile(resourcesFolder .. 'Scripts\\Verse.lua')
	dofile(resourcesFolder .. 'Scripts\\QuoteFile.lua')
	math.randomseed(os.time())
	-- Show the right verse immediately on load rather than waiting for the (possibly ignored) download:
	-- a custom verse, or an offline verse when online fetching is off.
	if customVerseEnabled() then
		applyCustomVerse()
	elseif not onlineFetchEnabled() then
		Offline()
	end
end

function Update()
	return 1
end

-- True when the skin is in custom-verse mode.
function customVerseEnabled()
	return tonumber(SKIN:GetVariable('CustomVerseEnabled')) == 1
end

-- True when fetching verses from the online API is enabled.
function onlineFetchEnabled()
	return tonumber(SKIN:GetVariable('OnlineFetchEnabled')) == 1
end

-- Show the next verse from the active source: the custom verse if enabled, a fresh online download if
-- online fetching is on, otherwise a new offline verse. Called by the next-verse control and the rotation
-- timer, and by the settings panel when the online-fetch toggle changes.
function nextVerse()
	if customVerseEnabled() then
		applyCustomVerse()
		return
	end
	if onlineFetchEnabled() then
		SKIN:Bang('!CommandMeasure', 'MeasureQuran', 'Update')
		SKIN:Bang('!UpdateMeasure', 'MeasureQuran')
		return
	end
	Offline()
end

-- Show the user's custom verse. The reference key is the manual chapter:verse, but only when BOTH numbers
-- are present; if either is empty the key is empty and the reference shows just the label (centered).
function applyCustomVerse()
	local customText = SKIN:GetVariable('CustomText')
	local suraNumber = SKIN:GetVariable('SuraNumber')
	local verseNumber = SKIN:GetVariable('VerseNumberManual')
	local verseKey = ''
	if suraNumber ~= nil and suraNumber ~= '' and verseNumber ~= nil and verseNumber ~= '' then
		verseKey = suraNumber .. ':' .. verseNumber
	end
	applyVerse(customText, verseKey)
end

-- Show the verse WebParser just parsed into the child measures (unless custom mode is on, or online
-- fetching is off in which case the initial background download is ignored and the offline verse stays).
function Online()
	if customVerseEnabled() then
		applyCustomVerse()
		return
	end
	if not onlineFetchEnabled() then
		return
	end
	local englishTranslation = SKIN:GetMeasure('MeasureEnglish'):GetStringValue()
	local verseKey = SKIN:GetMeasure('MeasureKey'):GetStringValue()
	applyVerse(englishTranslation, verseKey)
end

-- Fall back to a random line from @Resources\quotes.txt (unless custom mode is on). The bundled reference
-- is like "Quran X:Y"; take just the chapter:verse so the editable label is what shows in front of it.
function Offline()
	if customVerseEnabled() then
		applyCustomVerse()
		return
	end
	local offlineLines = readLines(SKIN:GetVariable('@') .. 'quotes.txt')
	if #offlineLines == 0 then
		return
	end
	local randomIndex = math.random(#offlineLines)
	local quoteText, reference = parseLine(offlineLines[randomIndex])
	local verseKey = reference:match('%d+:%d+')
	if verseKey == nil then
		verseKey = reference
	end
	applyVerse(quoteText, verseKey)
end

-- Called by the settings panel after it changes a reference or custom variable. Recomposes the display
-- without refetching: in custom mode it re-applies the custom verse; otherwise it recomposes only the
-- reference line so the current fetched verse stays put.
function refreshDisplay()
	if customVerseEnabled() then
		applyCustomVerse()
		return
	end
	refreshReference()
end
