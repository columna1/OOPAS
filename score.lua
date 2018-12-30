--[[
How to use:
make a new score object, this has to include the replay and map
the replay and map can be updated once the score is created
as they are only passed in by reference

The score HAS to be processed in object order. certain situations like
notelock can't be accounted for otherwise. *there may be some way to 
disable this and take care of edge cases for things like when you
only have part of a replay (spectating for example)

If you have all of a replay already loaded and ready to judge
then call score:judgeAll()
this will run through all the objects and jugde based on the
replay.
If you don't have all of the replay you can either call
score:judgeNextObject (judges the next unjudged object)
or 
score:judgeReplaySoFar (judges everything that can be in the replay)
-this function looks at the replay, finds the last object that *could*
be hit and judges up to that point

*possible way to judge partial replays
*set all needed info in the score directly
score.currentObject = x
score.totalScore = x
score.maxCombo = x
etc...
score:judgeNextObject()

Judging functions will act upon it's internal state. use that to update
any relivant information

perhapse judging functions should return info about what has been scored?
]]

local vec2 = require("vec2")

local score = {}
local newScore = {}

function score:reset()--resets all accumulated statistics
	self.totalScore = 0
	self.maxCombo = 0
	self.threeHundreds = 0
	self.oneHundreds = 0
	self.misses = 0
	self.currentObject = 0
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

function score:judgeCircle()
	
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
function score:judgeSlider()

end

function score:judgeNextObject()
	
end

--this runs through all the objects in the map and judges them all.
function score:judgeAll()
	for o = 1,#self.map.hitObjects do
		
	end
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
	--todo, more checking to make sure that what is passed in actually is the 
	--map and replay, or something that you can use as the map/replay to judge 
	--the score.
	local self = {}
	setmetatable(self,{__index = score})
	self.map = map
	self.replay = replay
	return self
end

return newScore