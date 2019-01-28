--todo, silently fail and return an error message, don't stop the whole program from running
local vec2 = require("vec2")
local sliderCalc = require("slidercurves")
require("util")
local map = {}
local prefile = {}

if bit then--we are running in luajit
	bit32 = bit
end

--defaults
map.section = ""
map.timingPoints = {}
map.hitObjects = {}
map.ar=0
map.cs=0
map.od=0
map.hp=0

function map:parseMetadataLine(line)
	local s,_ = line:find(":")
	if s then
		self[line:sub(1,s-1)] = line:sub(s+1)
	end
end

function map:parseTimingPoint(line)
	--tbc
	local td = line:split(",")
	local tp = {}
	tp.time = tonumber(td[1])
	tp.msPerBeat = tonumber(td[2])
	tp.meter = tonumber(td[3])
	tp.sampleSet = tonumber(td[4])
	tp.sampleIndex = tonumber(td[5])
	tp.volume = tonumber(td[6])
	tp.inherited = tonumber(td[7])
	tp.kai = tonumber(td[8])
	if tp.msPerBeat < 0 then --inherited
		--find last non-inherited timing point
		if #self.timingPoints == 0 then
			error("first timing point can't be inherited")
		end
		local lastNonInheritedPoint = 1
		if #self.timingPoints < 2 then
			for i = #self.timingPoints,1,-1 do
				if self.timingPoints[i].msPerBeat > 0 then
					lastNonInheritedPoint = i
					break
				end
			end
		end
		tp.inheritedMsPerBeat = self.timingPoints[lastNonInheritedPoint].msPerBeat * (math.abs(tp.msPerBeat)/100)
	else
		tp.inheritedMsPerBeat = tp.msPerBeat
	end
	table.insert(self.timingPoints,tp)
end

function difficultyrange(d,min,mid,max)
	if d > 5 then return mid + (max - mid) * (d - 5) / 5 end
	if d < 5 then return mid - (mid - min) * (5 - d) / 5 end
	return mid
end

function map:parseDifficultyLine(line)
	local s,_ = line:find(":")
	if s then
		local value = line:sub(1,s-1)
		if value == "ApproachRate" then self.ar = tonumber(line:sub(s+1))
		elseif value == "CircleSize" then
			self.cs = tonumber(line:sub(s+1))
			self.circleRadius = (-9*self.cs+109)/2
		elseif value == "HPDrainRate" then self.hp = tonumber(line:sub(s+1))
		elseif value == "OverallDifficulty" then 
			self.od = tonumber(line:sub(s+1))
			self.odms    = math.floor(difficultyrange(self.od,200,150,100))
			self.odms50  = self.odms
			self.odms100 = math.floor(difficultyrange(self.od,140,100,60 ))
			self.odms300 = math.floor(difficultyrange(self.od,80 ,50 ,20 ))
		elseif value == "SliderMultiplier" then self.sliderMultiplier = tonumber(line:sub(s+1))
		elseif value == "SliderTickRate" then self.sliderTickRate = tonumber(line:sub(s+1))
		elseif value == "StackLeniency" then self.stackLeniency = tonumber(line:sub(s+1))
		end
	end
end

function map:findTimingPoint(ms)
	for i = 1,#self.timingPoints do
		if self.timingPoints[i].time == ms then
			return self.timingPoints[i]
		end
		if self.timingPoints[i].time > ms then
			return self.timingPoints[i-1]
		end
	end
	--it's probably the last timing point
	return self.timingPoints[#self.timingPoints]
end

function map:parseHitObject(line)
	local sl = line:split(",")
	local obj = {}
	--x,y,time,type,hitSound...,extras
	obj.pos = vec2(tonumber(sl[1]),tonumber(sl[2]))
	obj.time = tonumber(sl[3])
	obj.type = tonumber(sl[4])
	if bit32.band(obj.type,1) > 0 then--circle
		obj.type = "circle"
	elseif bit32.band(obj.type,2) > 0 then--slider
		--x,y,time,type,hitSound,sliderType|curvePoints,repeat,pixelLength,edgeHitsounds,edgeAdditions,extras
		obj.type = "slider"
		local timingPoint = self:findTimingPoint(obj.time)
		obj.length = tonumber(sl[8])
		obj.duration = obj.length / (100 * self.sliderMultiplier) * timingPoint.inheritedMsPerBeat
		obj.repeats = tonumber(sl[7])
		--calculate slider path and ticks
		--slider is passed in by reference since that's how tables work in lua
		--this is weird and I don't like it but it's performant..
		--dbg()
		sliderCalc.calculatePath(sl[6],obj,timingPoint.msPerBeat,self.sliderTickRate)
	end
	table.insert(self.hitObjects,obj)
end

function map:parseline(line)
	local first = line:sub(1,1)
	if #line < 1 then
		return
	elseif first == " " or first == "_" or first == "/" then--comments
		return 
	elseif first == "[" then
		local s,_ = line:find("]")
		if s then
			self.section = line:sub(2,s-1)
			return
		else
			return--?wtf
		end
	end
	--we only care about stuff directly related to gameplay (for now), so no storyboard or combo colors, etc
	if self.section == "HitObjects" then self:parseHitObject(line) ; return end
	if self.section == "TimingPoints" then self:parseTimingPoint(line) ; return end
	if self.section == "Difficulty" then self:parseDifficultyLine(line) ; return end
	if self.section == "Metadata" then self:parseMetadataLine(line) ; return end
end

function map:parse(mapdata)
	if type(mapdata) == "string" then
		for line in mapdata:gmatch("[^\r\n]+") do
			self:parseline(line)
		end
	elseif type(mapdata) == "userdata" then
		for line in mapdata:lines() do
			self:parseline(line)
		end
	end
end

function prefile.new()
	local self = {}
	setmetatable(self,{__index = map})
	return self
end

return prefile