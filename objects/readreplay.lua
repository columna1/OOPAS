
-- Imports
local lzma = require("lzma")
local reader = require("../objects/binRead")
require("bit")

--this is just a simple* file reader, more advanced things can be done with your own reader

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
		
		--split up mods to make things easier for later
		replay.emods = {}
		replay.emods.nf = bit.band(replay.mods,1   ) > 0
		replay.emods.ez = bit.band(replay.mods,2   ) > 0
		replay.emods.hd = bit.band(replay.mods,8   ) > 0
		replay.emods.hr = bit.band(replay.mods,16  ) > 0
		replay.emods.dt = bit.band(replay.mods,64  ) > 0
		replay.emods.rl = bit.band(replay.mods,128 ) > 0
		replay.emods.ht = bit.band(replay.mods,256 ) > 0
		replay.emods.fl = bit.band(replay.mods,1024) > 0
		replay.emods.so = bit.band(replay.mods,4096) > 0
		
		replay.graph = read:readString()--life bar graph csv pairs
		replay.time = {read:readByte(),read:readByte(),read:readByte(),read:readByte(),read:readByte(),read:readByte(),read:readByte(),read:readByte()}--time stamp
		local len = read:readInt()--length of compressed replay
		replay.compressedData = read:readBytes(len)--compressed replay
		--replay.uncompressedData = lzma.uncompress(lzma_format(replay.compressedData))
		replay.uncompressedData = lzma.uncompress(replay.compressedData)
		replay.onlineID = read:readLong()--score's online id
	else
		error("Couldn't open replay file: "..err)
	end
	read:close()
	return replay
end
return readReplay