local readReplay = require("readreplay")
local vec2 = require("vec2")
require("util")
require("bit")

local prefile = {}
local replay = {}

--search returns the closest index to the requested timestamp
local function search(list,find)--simple binary search
	local L = 0
	local R  = #list
	local last = 0
	local itt = 0
	while L <= #list do
		itt = itt + 1
		local m = math.floor((L + R)/2)
		if last == m then
			assert(list[m].time <= find and list[m+1].time>=find,"this search is dumb")
			local dif1 = math.abs(list[m+1].time-find)
			local dif2 = math.abs(list[m  ].time-find)
			local dif3 = math.abs(list[m-1].time-find)
			if dif1 < dif2 then
				return m+1
			elseif dif3 < dif2 then
				return m-1
			else
				return m
			end
		elseif list[m].time < find then
			L = m + 1
		elseif list[m].time > find then
			R = m - 1
		elseif list[m].time == find then
			return m
		end
		last = m
	end
end

function replay:search(ms)
	return search(self.events,ms)
end

function replay:currentEvent()
	if self.offset < #self.events-1 then
		self.offset = self.offset + 1
	end
	return self.events[self.offset-1]
end

function replay:nextEvent()
	if self.offset < #self.events-1 then
		self.offset = self.offset + 1
	end
	return self.events[self.offset]
end

-- Seeks to the first event at or after the time
function replay:seekToTime(time)
	self.offset = search(self.events,time)
	return self.events[self.offset]
end


-- Wraps a file loaded from readReplay() with a stream
function prefile.wrap(rawReplay)
	local self = rawReplay
	self.offset = 1
	local events = {}

	--Parse events
	events = self.uncompressedData:split(",")
	local time = 0
	for i = 1,#events do
		--events[i] = events[i]:split("|")
		local event = events[i]:split("|")
		event.dms = tonumber(event[1])
		time = time + event.dms
		event.time = time
		event.pos = vec2(tonumber(event[2]),tonumber(event[3]))
		event.keys = tonumber(event[4])
		if bit.band(event.keys,0x5) > 0 then event.k1 = true end
		if bit.band(event.keys,0xA) > 0 then event.k2 = true end
		--events[i][1] = time
		events[i] = event
	end
	--events in a replay shouldn't be out of order
	--but events can have negative delta times
	--todo: investigate further
	
	self.events = events

	setmetatable(self, {__index = replay})
	return self
end


-- Takes a file object or string and returns the replay stream
function prefile.read(input)
	return prefile.wrap(readReplay(input))
end

return prefile