-- RandomAyah.lua : entry points the skin calls.
--   Online()   show the verse WebParser just downloaded
--   Offline()  show a random verse from the bundled quotes file
-- Helpers live in Verse.lua (applyVerse) and QuoteFile.lua (readLines, parseLine).

function Initialize()
	local resourcesFolder = SKIN:GetVariable('@')
	dofile(resourcesFolder .. 'Scripts\\Verse.lua')
	dofile(resourcesFolder .. 'Scripts\\QuoteFile.lua')
	math.randomseed(os.time())
end

function Update()
	return 1
end

-- Show the verse WebParser just parsed into the child measures.
function Online()
	local englishTranslation = SKIN:GetMeasure('MeasureEnglish'):GetStringValue()
	local verseKey = SKIN:GetMeasure('MeasureKey'):GetStringValue()
	applyVerse(englishTranslation, verseKey)
end

-- Fall back to a random line from @Resources\quotes.txt. The bundled reference is like "Quran X:Y"; take
-- just the chapter:verse so the editable label (ReferenceLabel) is what shows in front of it.
function Offline()
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
