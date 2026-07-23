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
	applyVerse(englishTranslation, 'Quran ' .. verseKey)
end

-- Fall back to a random line from @Resources\quotes.txt.
function Offline()
	local offlineLines = readLines(SKIN:GetVariable('@') .. 'quotes.txt')
	if #offlineLines == 0 then
		return
	end
	local randomIndex = math.random(#offlineLines)
	local quoteText, reference = parseLine(offlineLines[randomIndex])
	applyVerse(quoteText, reference)
end
