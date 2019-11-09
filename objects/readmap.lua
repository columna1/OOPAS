
--todo, silently fail and return an error message, don't stop the whole program from running
-- Imports
local vec2 = require("../objects/vec2")
local sliderCalc = require("../objects/slidercurves")
local util = require("../helpers/util")
local map = {}
local prefile = {}

if bit then--we are running in luajit
	bit32 = bit
end

function map:init()
	--defaults
	self.section = ""
	self.timingPoints = {}
	self.hitObjects = {}
	self.ar=0
	self.arTime = difficultyrange(self.ar,1800,1200,450)
	self.cs=0
	self.circleRadius = (-9*self.cs+109)/2
	self.od=0
	self.odms    = math.floor(difficultyrange(self.od,200,150,100))
	self.odms50  = self.odms
	self.odms100 = math.floor(difficultyrange(self.od,140,100,60 ))
	self.odms300 = math.floor(difficultyrange(self.od,80 ,50 ,20 ))
	self.hp=0
end

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
		if #self.timingPoints > 2 then
			for i = #self.timingPoints,1,-1 do
				if self.timingPoints[i].msPerBeat > 0 then
					lastNonInheritedPoint = i
					break
				end
			end
		end
		tp.inheritedFrom = self.timingPoints[lastNonInheritedPoint].msPerBeat
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

function map:parseGeneralLine(line)
	local s,_ = line:find(":")
	if s then
		local key = line:sub(1,s-1)
		local value = line:sub(s+1)
		if tonumber(value) then value = tonumber(value) end
		--print(key,value)
		self[key]=value
	end
end

function map:parseDifficultyLine(line)
	local s,_ = line:find(":")
	if s then
		local value = line:sub(1,s-1)
		if value == "ApproachRate" then 
			self.ar = tonumber(line:sub(s+1))
			self.arTime = difficultyrange(self.ar,1800,1200,450)
		elseif value == "CircleSize" then
			self.cs = tonumber(line:sub(s+1))
			self.circleRadius = (-9*self.cs+109)/2
		elseif value == "HPDrainRate" then 
			self.hp = tonumber(line:sub(s+1))
		elseif value == "OverallDifficulty" then 
			self.od = tonumber(line:sub(s+1))
			self.odms    = math.floor(difficultyrange(self.od,200,150,100))
			self.odms50  = self.odms
			self.odms100 = math.floor(difficultyrange(self.od,140,100,60 ))
			self.odms300 = math.floor(difficultyrange(self.od,80 ,50 ,20 ))
		elseif value == "SliderMultiplier" then 
			self.sliderMultiplier = tonumber(line:sub(s+1))
		elseif value == "SliderTickRate" then 
			self.sliderTickRate = tonumber(line:sub(s+1))
		elseif value == "StackLeniency" then 
			self.stackLeniency = tonumber(line:sub(s+1))
		end
	end
end

function map:findTimingPoint(ms)
	for i = 1,#self.timingPoints do
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
		sliderCalc.calculatePath(sl[6],obj,timingPoint.msPerBeat,self.sliderTickRate)
	end
	table.insert(self.hitObjects,obj)
end

function map:parseline(line)
	local first = line:sub(1,1)
	if #line <= 1 then
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
	if self.section == "General" then self:parseGeneralLine(line) ; return end
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
			self:parseline(line:gsub("[\r\n]",""))
		end
	end
	self:applyStacking()
end

function map:applyStacking()
	local stack_distance = 3
	--pretty much a port of lazer's code https://github.com/ppy/osu/blob/63b596f75a2b89f49cf2222f36bbae34a3d09aea/osu.Game.Rulesets.Osu/Beatmaps/OsuBeatmapProcessor.cs#L24
	for i = #self.hitObjects,1,-1 do
		self.hitObjects[i].stackHeight = 0
	end
	
	local eei = #self.hitObjects
	esi = 0
	for i = eei,1,-1 do
		n = i
		
		objectI = self.hitObjects[i]
		if not (objectI.stackHeight ~= 0 or objectI.type == "spinner") then 
			stackThreshold = self.arTime * self.StackLeniency
			
			if objectI.type == "circle" then
				n = n - 1
				while n > 0 do
					local objectN = self.hitObjects[n]
					if objectN ~= "spinner" then 
						endtime = objectN.duration and objectN.time+objectN.duration or objectN.time
						if objectI.time-endtime > stackThreshold then break end
						if n < esi then
							objectN.stackHeight = 0
							esi = n
						end
						
						--special case where objects are moved down and to the right
						if objectN.type == "slider" then 
							local NEndpoint = objectN.endPoint+objectN.pos
							if (NEndpoint-objectI.pos).length < stack_distance then--stack down and to the right
								local offset = objectI.stackHeight - objectN.stackHeight + 1
								for j = n,i do
									objectJ = self.hitObjects[j]
									if (NEndpoint-objectJ.pos).length < stack_distance then
										objectJ.stackHeight = objectJ.stackHeight - offset
									end
								end
								break
							end
						end
						if (objectN.pos-objectI.pos).length < stack_distance then
							objectN.stackHeight = objectI.stackHeight + 1
							objectI = objectN
						end
					end
					n = n - 1
				end
			elseif objectI.type == "slider" then
				n = n - 1
				while n > 0 do
					objectN = self.hitObjects[n]
					if objectN.type ~= "spinner" then 
						if objectI.time-objectN.time > stackThreshold then break end
						objectN.endPoint = objectN.endPoint and objectN.endPoint or objectN.pos
						if (objectN.endPoint-objectI.pos).length < stack_distance then
							objectN.stackHeight = objectI.stackHeight + 1
							objectI = objectN
						end
					end
					n = n - 1
				end
			end
		end
	end
	local scale = (1 - 0.7 * (self.cs - 5) / 5) / 2
	
	--print(64 * scale,self.circleRadius)
	--self.circleRadius = 64 * scale
	for i = 1,#self.hitObjects do
		self.hitObjects[i].originalPos = self.hitObjects[i].pos
		if self.hitObjects[i].stackHeight then
			--todo: when sliders are done, offset all it's points
			local off =self.hitObjects[i].stackHeight * scale * -6.4
			self.hitObjects[i].pos = self.hitObjects[i].pos + off
		end
	end
	return map
end

function prefile.new()
	local self = {}
	setmetatable(self,{__index = map})
	self:init()
	return self
end

return prefile