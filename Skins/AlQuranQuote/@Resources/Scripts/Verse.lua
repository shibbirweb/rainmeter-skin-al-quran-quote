-- Verse.lua : push a verse into the skin's display variables.

-- Build the reference line from the label, the verse key and the two show toggles. Kept as one composed
-- string (not "#ReferenceLabel# #VerseKey#" in the meter) so either part can be hidden and a lone label
-- has no trailing space, which keeps it centered when there is no number. Global so RandomAyah.lua can use
-- it too. The verseKey is passed in (never read back right after it is set with a queued bang).
-- useLabel is false for offline verses: their reference (the text after "|" in quotes.txt) is shown
-- verbatim as the whole reference, with no "Al Quran" label in front. Online and custom verses pass true.
function composeReferenceText(verseKey, useLabel)
	if useLabel == nil then
		useLabel = true
	end
	local showLabel = useLabel and (tonumber(SKIN:GetVariable('ShowReferenceLabel')) == 1)
	local showNumber = tonumber(SKIN:GetVariable('ShowVerseNumber')) == 1

	local labelPart = ''
	if showLabel then
		labelPart = SKIN:GetVariable('ReferenceLabel')
	end

	local keyPart = ''
	if showNumber and verseKey ~= nil and verseKey ~= '' then
		keyPart = verseKey
	end

	if labelPart ~= '' and keyPart ~= '' then
		return labelPart .. ' ' .. keyPart
	end
	if labelPart ~= '' then
		return labelPart
	end
	return keyPart
end

-- Write the shown verse to LastVerse.inc so it is restored on the next Rainmeter start (that file is
-- UTF-16, so Unicode verse text persists). VersePersisted flips to 1 so the load logic keeps it.
local function persistLastVerse(quoteText, verseKey, useLabelFlag, refText)
	local file = SKIN:GetVariable('@') .. 'LastVerse.inc'
	SKIN:Bang('!WriteKeyValue', 'Variables', 'QuoteText', quoteText, file)
	SKIN:Bang('!WriteKeyValue', 'Variables', 'VerseKey', verseKey, file)
	SKIN:Bang('!WriteKeyValue', 'Variables', 'RefText', refText, file)
	SKIN:Bang('!WriteKeyValue', 'Variables', 'RefUseLabel', useLabelFlag, file)
	SKIN:Bang('!WriteKeyValue', 'Variables', 'VersePersisted', 1, file)
end

-- Set the quote text and verse key, compose the reference, persist it, then repaint. useLabel (default
-- true) records whether the label may prefix the reference, so refreshReference can recompose the same way.
function applyVerse(quoteText, verseKey, useLabel)
	if quoteText == nil then
		quoteText = ''
	end
	if verseKey == nil then
		verseKey = ''
	end
	if useLabel == nil then
		useLabel = true
	end
	local useLabelFlag = 1
	if not useLabel then
		useLabelFlag = 0
	end
	local refText = composeReferenceText(verseKey, useLabel)
	SKIN:Bang('!SetVariable', 'QuoteText', quoteText)
	SKIN:Bang('!SetVariable', 'VerseKey', verseKey)
	SKIN:Bang('!SetVariable', 'RefUseLabel', useLabelFlag)
	SKIN:Bang('!SetVariable', 'RefText', refText)
	persistLastVerse(quoteText, verseKey, useLabelFlag, refText)
	SKIN:Bang('!UpdateMeter', '*')
	SKIN:Bang('!Redraw')
end

-- Recompose the reference from the CURRENT verse key without touching the quote, used when only the label
-- or a show toggle changed so the displayed verse must not move. VerseKey and RefUseLabel are read here
-- (both were set on a previous call, not in this one, so the values are current).
function refreshReference()
	local verseKey = SKIN:GetVariable('VerseKey')
	local useLabel = tonumber(SKIN:GetVariable('RefUseLabel')) == 1
	local refText = composeReferenceText(verseKey, useLabel)
	SKIN:Bang('!SetVariable', 'RefText', refText)
	SKIN:Bang('!WriteKeyValue', 'Variables', 'RefText', refText, SKIN:GetVariable('@') .. 'LastVerse.inc')
	SKIN:Bang('!UpdateMeter', '*')
	SKIN:Bang('!Redraw')
end
