local readReplay = require("readreplay")

local prefile = {}
local replay = {}


function replay:nextEvent()
	-- Stub
end


-- Seeks to the first event at or after the time
function replay:seekToTime(time)
	-- Stub
end


-- Wraps a file loaded from readReplay() with a stream
function prefile.wrap(rawReplay)
	local self = {}
	self.offset = 1

	-- Sort into events


	setmetatable(self, {__index = replay})
	return self
end


-- Takes a file object or string and returns the replay stream
function prefile.read(input)
	return prefile.wrap(readReplay(input))
end

return prefile