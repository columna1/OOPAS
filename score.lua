local vec2 = require("vec2")
local rps = require("replaystream")
require("bit")
require("util")

local score = {}
local newScore = {}

function score:reset()--resets all accumulated statistics
	self.totalScore = 0
	self.maxCombo = 0
	self.threeHundreds = 0
	self.oneHundreds = 0
	self.misses = 0
	self.currentObject = 0
	self.isHit = {}

	--gives info about all clicks
	self.hitInfo = {}
	--temporary
	self.hitErrors = {}
end

function isInRad(pos1,pos2,rad,radMult)
	--find distance
	if not radMult then radMult = 1 end
	--local distance = math.sqrt(math.abs(x1-x2)^2+math.abs(y1-y2)^2)
	local distance = math.abs((pos1-pos2).length)
	return distance <= (rad*radMult)
end

--find the first click from the between the given indexes
function score:findClick(startInd,endInd)
	local lk1,lk2 = false,false
	if startInd > 1 then
		lk1,lk2 = self.replay.events[startInd-1].k1,self.replay.events[startInd-1].k2
	end	
	for i = startInd,endInd do
		local k1,k2 = self.replay.events[i].k1,self.replay.events[i].k2
		local ret = 0
		if k1 and not lk1 then
			--return i,1
			ret = ret + 1
		end
		if k2 and not lk2 then
			--return i,2
			ret = ret + 2
		end
		if ret > 0 then
			return i,ret
		end
		lk1,lk2 = k1,k2
	end
	return false,0
end
--most of the logic for judging circles/slider heads because they are so similar
function score:judgeHead(o)
	--find the first click within the judge window
	--local firstReplayPoint = self.replay:search(self.map.hitObjects[o].time-self.map.odms)
	local firstReplayPoint = -1
	local lastReplayPoint = self.replay:search(self.map.hitObjects[o].time+self.map.odms)

	if o > 1 then
		if self.isHit[o-1] then
			if self.isHit[o-1].time >= self.map.hitObjects[o].time-self.map.odms then
				--start searching from where the last note was hit since we can't
				--count that for our current note
				firstReplayPoint = self.replay:search(self.isHit[o-1].time)+1
			end
		end
	end
	if firstReplayPoint == -1 then
		firstReplayPoint = self.replay:search(self.map.hitObjects[o].time-self.map.odms)
	end
	
	local function getscore(ms)--only ever called if it's been confirmed hit
		ms = math.abs(ms)
		if ms < self.map.odms300 then
			return 300
		elseif ms < self.map.odms100 then
			return 100
		else
			return 50
		end
	end
	
	res,key = self:findClick(firstReplayPoint,lastReplayPoint)
	firstReplayPoint = res + 1
	while res ~= false do
		--attempt to make things more readable
		local point = self.replay.events[res]
		local curObj = self.map.hitObjects[o]
		local lastObj = 0
		--check to see if the last object's hit window overlaps with the one we
		--are currently checking, if it does, make sure it's been hit
		--if it hasn't been hit then make sure the hit we are checking isn't in
		--the last note's hit window.

		if o > 1 then
			lastObj = self.map.hitObjects[o-1]
		end

		if o == 1 or (not (point.time <= lastObj.time+self.map.odms and (not self.isHit[o-1]))) then
			if isInRad(self.map.hitObjects[o].pos,point.pos,self.map.circleRadius) then
				--we have hit the circle
				local he = point.time-self.map.hitObjects[o].time
				return he,getscore(he),point.time
			end
		end
		res,key = self:findClick(firstReplayPoint,lastReplayPoint)
		firstReplayPoint = res + 1
	end
	return false
end

--[[
Circle judging depends on two factors; CS and OD.

CS: the size of the cicle. Osu works with a playfield of 512x384, the radius of 
a cirle in that playfeld can be calculated using the formula: "(-9*cs+109)/2". 
There are alternative forms of the fomula but this is what I decided to use.

The values for OD are calculated as so: We use a function named 
"difficultyRange", The source was taken from lazer. read readmap.lua for more 
information.

A circle is only judged if it is the earliest object that hasn't been hit, 
missed, or it's judge window has lapsed. This causes an effect commonly refered 
to as "note lock". Durring the hit window of the cicle we look to see If the 
circle meets these conditions then when the user presses a key, either k1(mouse 
button1 or keyboard button 1) or k2(mouse button 2 or keyboard button 2) we look 
to see if the user is inside of the cirle's radius and then count as a hit or 
miss based on when the circle was hit.

Combo: if the circle was hit then we increment the current combo, if it was 
missed then the combo is reset.

**may be innacurate**
*taken from the osu wiki
Scoring: Score is added onto the total score based on
this formula:
"Score = Hit Value + (Hit Value * ((Combo multiplier * Difficulty multiplier * Mod multiplier) / 25))"
Where hit value is the score achieved (50,100,300) slider
ticks or spinner bonuses
Combo Multiplier is combo before this hit-1 or 0 which
ever one is higher
Mod multiplier, multiplier of selected mods 
Difficulty multiplier calculated as so:
CS, HP, and OD all give "difficulty points"
for original difficulty values only, (before mods)
0-5   difficulty points gives a 2xmultiplier
6-12  gives 3x
13-17 gives 4x
18-24 gives 5x
25-30 gives 6x

]]--

function score:judgeCircle(o)
	local hitError,score,time = self:judgeHead(o)
	if hitError then
		table.insert(self.hitErrors,hitError)
		self.isHit[o] = {}
		--print("hit",o,time)
		self.isHit[o].time = time
	else
		--print("miss "..o)
	end
end

--[[
Sliders are judged in several parts;

First is the slider head which is very much like a normal circle.

Next are the ticks, this includes repeat arrows, they count as ticks. Ticks are
 count as hit if the follow circle is active. To be active the cursor needs to be 
in a 1xradius of where the slider currently is in it's curve and have a key held
down*. When the follow circle is active it's radius is something like 2.3x a 
circle's radius, if you exit this radius it's no longer active. If the follow 
circle is active when the tick happens then that tick is counted as hit.

*note, odd behavior for follow circles*
**todo: finish (this info may be innacurate)
The slider follow cirle only counts a key being held down when the key was 
pressed durring a slider's active time ie. when the slider can first be judged to 
when the slider end happens. Except when the key pressed was used to hit a circle 
or another slider and wasn't let go. There may be some odd behavior having to do 
with what key was used to press something and when but I'm not sure.

Last is the slider end. the time of the slider end is a constant 36ms early 
unless the slider's total duration is less than 72ms, in such a case the slider 
end happens at the total duration/2ms. Other than that, the slider end is judged 
much like a slider tick.

Combo for a slider is decided as so: Each element of a slider, such as the 
head/ticks/end all increment the current combo. If a slider head or a slider 
tick/repeat point is missed then the combo will reset after the combo achieved 
for the slider is added to the current combo. If a slider end is missed then the 
user missed out on the combo for that slider end but the combo isn't reset.

*may be innacurate*
Scoring is decided like so: All possible elements that you can hit are tallied 
up into a total, if the user hit all those possible elements then the slider is 
scored as a circle where a 300 was achieved, else if the user hit half or more 
of the possible hit elements then the slider is scored as a 100, if they hit some
elements, but less than half it's scored as a 50. If they hit none, it's a miss. 
Slider Heads, slider repeats, and slider ends all give a fixed 30 points towards 
the score. Slider ticks give a fixed 10 points. After the slider ends and the 
score is found, the score is treated like a cirle and added onto the total score.
]]--
function score:judgeSlider(o)
	local hitError,score,time = self:judgeHead(o)
	if hitError then
		table.insert(self.hitErrors,hitError)
		self.isHit[o] = {}
		self.isHit[o].time = time
	end
end

function score:judgeNextObject(objnum)
	
end

--this runs through all the objects in the map and judges them all.
function score:judgeAll()
	self:reset()
	for o = 1,#self.map.hitObjects do
		local object = self.map.hitObjects[o]
		if object.type == "slider" then
			self:judgeSlider(o)
		elseif object.type == "circle" then
			self:judgeCircle(o)
		end
	end

	
	--printTable(self.hitErrors)
	--this is temporary!!
	gt = cull(self.hitErrors,function(a) return a < 0 end)
	lt = cull(self.hitErrors,function(a) return a >= 0 end)
	print("Error: "..average(lt).."ms - "..average(gt).."ms avg")
	print("Unstable Rate: ",round(standardDeviation(self.hitErrors)*10))
end
 
--this function can be used in situations when you don't have the whole replay yet
function score:judgeReplaySoFar()

end

function newScore.new(map,replay) 
	if not map or not replay then
		return nil
	elseif type(map) ~= "table" or type(replay) ~= "table" then
		return nil
	end

	--check if the replay is wrapped/parsed yet, if not,
	--wrap it in replay stream
	if not replay.events then
		replay = rps.wrap(replay)
	end
	
	--todo, more checking to make sure that what is passed in actually is the 
	--map and replay, or something that you can use as the map/replay to judge 
	--the score.
	local self = {}
	setmetatable(self,{__index = score})
	self.map = map
	self.replay = replay
	self.isHit = {}
	return self
end

return newScore