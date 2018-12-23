local vec2 = require("vec2")
require("util")

local function calculatePath(curve,slider,nonInheritedBPM,sliderTickRate)
	slider.path = {}
	
	--turning the slider string into a set of points
	local rawPath = curve:split("|")
	slider.pathType = table.remove(rawPath,1)
	for i = 1,#rawPath do
		local p = rawPath[i]:split(":")
		rawPath[i] = vec2(tonumber(p[1]),tonumber(p[2]))-slider.pos
	end
	
	table.insert(rawPath,1,vec2(0))
	subControlPoints = {}
	--splitting the slider into seperate curves 
	for i = 1,#rawPath do
		table.insert(subControlPoints,rawPath[i])
		if i == #rawPath or rawPath[i] == rawPath[i+1] then
			--calculating the curve's path
			subpath = calculateSubPath(slider.pathType,subControlPoints)
			if subpath then
				for j = 1,#subpath do
					if #slider.path == 0 or subpath[j] ~= slider.path[#slider.path] then
						--adding to the slider's path
						table.insert(slider.path,subpath[j])
					end
				end
			end
			
			subControlPoints = {}
		end
	end
	
	calcLenAndResize(slider)
	
	slider.ticks = {}
	local msPerTick = nonInheritedBPM/sliderTickRate
	local offsets = {}
	local lasttime = 0
	for i = 1,math.floor(slider.duration/msPerTick) do --find tick positions and add them to the slider
		if not almostEquals(slider.duration,msPerTick*i) then
			table.insert(slider.ticks,{vec2(getPointAt(msPerTick*i/slider.duration,slider)),msPerTick*i})
			table.insert(offsets,msPerTick*i-lasttime)
			lasttime = msPerTick*i
		end
	end
	table.insert(offsets,slider.duration-lasttime)
	
	
	local function reverseTable(t)
		local nt = {}
		for i = 1,#t do
			nt[i] = t[#t-(i-1)]
		end
		return nt
	end
	
	
	slider.endPoint = vec2(slider.path[#slider.path])
	slider.repeatPoints = {}
	local fep = vec2(slider.endPoint)
	--adding ticks for repeat sliders.
	if slider.repeats > 1 and #slider.ticks > 0 then
		local revdir = true
		for r = 1,slider.repeats-1 do
			local totalms = slider.duration*r
			if revdir then --add a tick at the end of the slider, and make the end the start
				table.insert(slider.ticks,{vec2(slider.endPoint),slider.duration*r})
				table.insert(slider.repeatPoints,#slider.ticks)
				slider.endPoint = vec2(slider.path[1])
			else
				table.insert(slider.ticks,{vec2(slider.endPoint),slider.duration*r})
				table.insert(slider.repeatPoints,#slider.ticks)
				slider.endPoint = vec2(fep)
			end
			--add the ticks to the slider in reverse order from the last set or smth
			for i = 1,#offsets-1 do
				local oftab = {}
				if revdir then
					oftab = reverseTable(offsets)
					totalms = totalms + offsets[#offsets-i+1]
					table.insert(slider.ticks,{vec2(slider.ticks[#offsets-i][1]),totalms})
				else
					oftab = offsets
					totalms = totalms + offsets[i]
					table.insert(slider.ticks,{vec2(slider.ticks[i][1]),totalms})
				end
			end
			revdir = not revdir
		end
	elseif slider.repeats > 1 and #slider.ticks == 0 then
		--no tick manipulating, just flipping the slider end
		local revdir = true
		for r = 1,slider.repeats-1 do
			if revdir then --add a tick at the end of the slider, and make the end the start
				table.insert(slider.ticks,{vec2(slider.endPoint),slider.duration*r})
				table.insert(slider.repeatPoints,#slider.ticks)
				slider.endPoint = vec2(slider.path[1])
			else
				table.insert(slider.ticks,{vec2(slider.endPoint),slider.duration*r})
				table.insert(slider.repeatPoints,#slider.ticks)
				slider.endPoint = vec2(fep)
			end
			revdir = not revdir
		end
	end
	slider.totalDuration = slider.duration * slider.repeats
	return slider
end

function indexOfDistance(d,slider)--simple binary search
	local L = 0
	local R  = #slider.cumulativeLength
	local last = 0
	local itt = 0
	while L <= #slider.cumulativeLength do
		itt = itt + 1
		local m = math.max(math.floor((L + R)/2),1)
		if last == m then
			assert(slider.cumulativeLength[m] <= d and slider.cumulativeLength[m+1]>=d,"this search is dumb")
			return m
		elseif slider.cumulativeLength[m] < d then
			L = m + 1
		elseif slider.cumulativeLength[m] > d then
			R = m - 1
		else
			return m
		end
		last = m
	end
	return #slider.cumulativeLength
end

function progressToDistance(progress,slider)
	return math.min(math.max(progress,0),1) * slider.length
end

--**the rest of this code is pretty much a direct port of osu!lazer's code for sliders**--

local function interpolateVerticies(i,d,s)
	--i = i + 1
	if #s.path == 0 then return vec2() end
	if i <=0 then
		return s.path[1]
	elseif i >= #s.path then
		return s.path[#s.path]
	end
	
	local p0 = s.path[i]
	local p1 = s.path[i+1]
	
	local d0 = s.cumulativeLength[i]
	local d1 = s.cumulativeLength[i+1]
	
	if almostEquals(d0,d1) then
		return p0
	end
	
	local w = (d-d0)/(d1-d0)
	return p0+(p1-p0) * w
end

--function get
function getPointAt(progress,slider)
	if math.floor(progress % 2) == 1 then--account for repeats
		progress = 1- ( progress %1 )
	else
		progress = progress % 1
	end
	local d = progressToDistance(progress,slider)
	return interpolateVerticies(indexOfDistance(d,slider),d,slider)-- + offset
end

function calculateSubPath(typ,path)
	if typ == "B" then
		return bezierCurve(path).createBezier()
	end
	if typ == "C" then
		return catmullCurve(path).createCatmull()
	end
	if typ == "L" then
		return path
	end
	if typ == "P" then
		if #path ~= 3 then
			return
		end
		return perfectCurve(path).createArc()
	end
end

function almostEquals(n,t)
	local acceptableDifference = 0.001
	if math.abs(n-t) <= acceptableDifference then
		return true
	end
end

function calcLenAndResize(slider)
	slider.cumulativeLength = {}
	local l = 0
	table.insert(slider.cumulativeLength,l)
	
	local function removeRange(s,e)
		for _ = 1,e do 
			table.remove(slider.path,s)
		end
	end
	
	for i = 1,#slider.path-1 do
		local diff = slider.path[i+1] - slider.path[i]
		local d = diff.length
		if slider.length-l < d then
			slider.path[i+1] = slider.path[i] + diff * ((slider.length-l)/d)
			removeRange(i+2,#slider.path - 1 - i)
			
			l = slider.length
			table.insert(slider.cumulativeLength,l)
			break
		end
		
		l = l + d
		table.insert(slider.cumulativeLength,l)
	end
	
	if l < slider.length and #slider.path > 1 then
		local diff = slider.path[#slider.path] - slider.path[#slider.path-1]
		local d = diff.length
		
		if d <= 0 then
			return
		end
		
		slider.path[#slider.path] = slider.path[#slider.path] + diff * ((slider.length-l)/d)
		slider.cumulativeLength[#slider.path] = slider.length
	end
end

--[[------------------BEZIER------------------]]--

function bezierCurve(points)
	local self = {points = points,
		subdivisionBuffer1 = {vec2()},
		subdivisionBuffer2 = {vec2()}
		}
	local tolerance = 0.25
	local tolerance_sq = tolerance^2
	for a = 1,#self.points do
		self.points[a] = vec2(self.points[a])
	end
	local function isFlatEnough(point)
		for i =2,#point-1 do
			if (point[i-1] - 2 * point[i] + point[i+1]).lengthSquared > tolerance_sq * 4 then
				return false
			end
		end
		
		return true
	end
	local function subdivide(controlPoints,l,r)
		midpoints = self.subdivisionBuffer1
		local count = #controlPoints
		for i = 1,count do
			midpoints[i] = vec2(controlPoints[i])
		end
		
		for i = 1,count do
			l[i] = midpoints[1]
			r[count - (i-1)] = midpoints[count - (i-1)]
			
			for j = 1,count-i do
				midpoints[j] = (midpoints[j] + midpoints[j + 1])/2
			end
		end
		return l,r
	end
	
	function approximate(controlPoints,output)
		local r,l = self.subdivisionBuffer1,self.subdivisionBuffer2
		l,r = subdivide(controlPoints,l,r)
		
		local count = #controlPoints
		for i = 1,count do
			l[count + i] = r[i + 1]
		end
		table.insert(output,controlPoints[1])
		for i = 1,count-2 do
			local index = 2 * i
			p = 0.25 * (l[index] + 2 * l[index+1] + l[index + 2])
			table.insert(output,p)
		end
	end
	
	function copyTable(t)
		local r = {}
		for i = 1,#t do
			r[i] = t[i]
		end
		return r
	end
	
	local function createBezier()
		local output = {}
		if #self.points == 0 then return output end
		
		local toflatten = {}
		local freeBuffers = {}
		
		table.insert(toflatten,copyTable(self.points))
		leftChild = self.subdivisionBuffer2
		local count = #self.points
		while #toflatten > 0 do
			local parent = table.remove(toflatten)
			if isFlatEnough(parent) then
				approximate(parent,output)
				table.insert(freeBuffers,parent)
				--continue
			else
				local rightChild = #freeBuffers > 0 and table.remove(freeBuffers) or vec2()
				leftChild,rightChild = subdivide(parent,leftChild,rightChild)
			
				for i = 1,count do
					local t = leftChild[i]
					parent[i] = t
				end
				table.insert(toflatten,rightChild)
				table.insert(toflatten,parent)
			end
		end
		table.insert(output,self.points[#self.points])
		return output
	end
	
	return {
		createBezier = createBezier
	}
end

--[[------------------Catmull------------------]]--

--!!!!!WARNING UNTESTED!!!!!--
function catmullCurve(points)
	local self = {points = points}
	local detail = 50
	
	local function findPoint(vec1,ivec2,vec3,vec4,t)
		local t2 = t * t
		local t3 = t * t2
		
		local res = vec2()
		res.x = 0.5 * (2 * ivec2.X + (-vec1.X + vec3.X) * t + (2 * vec1.X - 5 * ivec2.X + 4 * vec3.X - vec4.X) * t2 + (-vec1.X + 3 * ivec2.X - 3 * vec3.X + vec4.X) * t3)
		res.y = 0.5 * (2 * ivec2.Y + (-vec1.Y + vec3.Y) * t + (2 * vec1.Y - 5 * ivec2.Y + 4 * vec3.Y - vec4.Y) * t2 + (-vec1.Y + 3 * ivec2.Y - 3 * vec3.Y + vec4.Y) * t3)
		return res
	end
	
	local function createCatmull() 
		local res = {}
		
		for i = 1,#self.points do
			local v1 = i > 0 and self.points[i-1] or self.points[i]
			local v2 = self.points[i]
			local v3 = i < #self.points - 1 and self.points[i+1] or v2 + v2 - v1
			local v4 = i < #self.points - 2 and self.points[i+2] or v3 + v3 - v2
			
			for c = 1,detail do
				table.insert(res,findPoint(v1,v2,v3,v4,c/detail))
				table.insert(res,findPoint(v1,v2,v3,v4,c+1/detail))
			end
		end
		return res
	end
	
	return {createCatmull = createCatmull}
end

--[[------------------Perfect------------------]]--

function perfectCurve(points)
	self = {
		a = points[1],
		b = points[2],
		c = points[3]
		}
	
	local tolerance = 0.1
	
	function dotprod(a, b)
		local ret = 0
		for i = 1, #a do
			ret = ret + a[i] * b[i]
		end
		return ret
	end
	
	local function createArc()
		local aSq = (self.b - self.c).lengthSquared
		local bSq = (self.a - self.c).lengthSquared
		local cSq = (self.a - self.b).lengthSquared
		
		if almostEquals(aSq, 0) or almostEquals(bSq, 0) or almostEquals(cSq, 0) then
			return {}
		end
		
		local s = aSq * (bSq + cSq - aSq)
		local t = bSq * (aSq + cSq - bSq)
		local u = cSq * (aSq + bSq - cSq)
		
		local sum = s + t + u
		if almostEquals(sum,0) then
			return {}
		end
		
		local center = (s * self.a + t * self.b + u * self.c) / sum
		local dA = vec2(self.a - center)
		local dC = vec2(self.c - center)
		
		local r = dA.length
		
		local thetaStart = math.atan2(dA.y,dA.x)
		local thetaEnd = math.atan2(dC.y,dC.x)
		
		while thetaEnd < thetaStart do
			thetaEnd = thetaEnd + 2 * math.pi
		end
		
		local dir = 1
		local thetaRange = thetaEnd - thetaStart
		
		local orthoAtoC = vec2(self.c - self.a)
		orthoAtoC = vec2(orthoAtoC.y,-orthoAtoC.x)
		if dotprod(orthoAtoC,vec2(self.b-self.a)) < 0 then
			dir =-dir
			thetaRange = 2 * math.pi - thetaRange
		end
		
		local ammountpoints = 2 * r <= tolerance and 2 or math.max(2,math.ceil(thetaRange / (2 * math.acos(1 - tolerance / r))));
		local output = {}
		for i = 0,ammountpoints-1 do
			local fract = i/(ammountpoints-1)
			local theta = thetaStart + dir * fract * thetaRange
			local o = vec2(math.cos(theta),math.sin(theta)) * r
			table.insert(output,center + o)
		end
		return output
	end
	
	return{createArc = createArc}
end

return {
	calculatePath = calculatePath
	}