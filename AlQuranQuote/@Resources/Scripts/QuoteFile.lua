-- QuoteFile.lua : read and parse the offline quotes file.
-- Each line is "English text | Quran X:Y".

-- Return every non-blank line of the file at `filePath` as a table.
function readLines(filePath)
	local nonBlankLines = {}
	local fileHandle = io.open(filePath, 'r')
	if fileHandle == nil then
		return nonBlankLines
	end
	for currentLine in fileHandle:lines() do
		if currentLine:match('%S') then
			table.insert(nonBlankLines, currentLine)
		end
	end
	fileHandle:close()
	return nonBlankLines
end

-- Split one "quote | reference" line into (quoteText, reference).
function parseLine(quoteLine)
	return quoteLine:match('^%s*(.-)%s*|%s*(.-)%s*$')
end
