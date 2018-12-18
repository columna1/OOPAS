local lzma = require("lzma")
local reader = require("binRead")
require("bit")

local function lzma_format(data)--transform standard lzma files to a format the library understands (shuffle arround the header)
--	+------------+----+----+----+----+--+--+--+--+--+--+--+--+
--	| Properties |  Dictionary Size  |   Uncompressed Size   |
--	+------------+----+----+----+----+--+--+--+--+--+--+--+--+
	local header = data:sub(0,13)
	local dat = data:sub(14)
	dat = header:sub(6,9):reverse()..header:sub(10)..header:sub(0,5)..dat
	return dat
end

--takes in a file object or a string
local function readReplay(input)
	read,err = reader.new(input)
	local replay = {}
	if read then
		replay.mode = read:readByte()--mode
		replay.gameVersion = read:readInt()--version of game
		replay.beatmapHash = read:readString()--beatmap hash
		replay.player = read:readString()--player name
		replay.replayHash = read:readString()--replay hash(certain parts)
		replay.threehundreds = read:readShort()--300s
		replay.onehundreds = read:readShort()--100s
		replay.fifties = read:readShort()--50s
		replay.gekies = read:readShort()--gekis
		replay.katsus = read:readShort()--katsus
		replay.misses = read:readShort()--misses
		replay.score = read:readInt()--score
		replay.combo = read:readShort()--max combo
		replay.fc = read:readBool()--fc combo
		replay.mods = read:readInt()--mods
		replay.graph = read:readString()--life bar graph csv pairs
		replay.time = {read:readByte(),read:readByte(),read:readByte(),read:readByte(),read:readByte(),read:readByte(),read:readByte(),read:readByte()}--time stamp
		local len = read:readInt()--length of compressed replay
		replay.compressedData = read:readBytes(len)--compressed replay
		replay.uncompressedData = lzma.uncompress(lzma_format(replay.compressedData))
		replay.onlineID = read:readLong()--score's online id
	else
		error("Couldn't open replay file: "..err)
	end
	read:close()
	return replay
end
return readReplay