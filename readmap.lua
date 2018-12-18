local map = {}
local prefile = {}

function string.split (str,sep)
	if type(str)=="number" or type(str)=="boolean" then
		str = tostring(str) -- Convert the bad object to a string.
	elseif type(str)=="table" then
		error("Cannot split a table.") -- You cannot simply tostring a table. Besides, I doubt anyone would like to do this anyways.
	end
	local return_array = {} -- The return value.
	sep = sep or "%s" -- Lua space value is %s
	for Lstr_01 in string.gmatch(str, "([^"..sep.."]+)") do
		return_array[#return_array+1] = Lstr_01
	end
	return return_array
end

--map.currentPos = 0
map.section = ""
map.timingPoints = {}

function map:parseMetadataLine(line)
	local s,_ = line:find(":")
	if s then
		self[line:sub(1,s-1)] = line:sub(s+1)
		print(line:sub(1,s-1),line:sub(s+1))
	end
end

function map:parseTimingPoint(line)
	--tbc
end

function map:parseline(line)
	local first = line:sub(1,1)
	if first == " " or first == "_" or first == "/" then--comments
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
	if self.section == "Metadata" then self:parseMetadataLine(line) ; return end
	if self.section == "TimingPoints" then self:parseTimingPoint(line) ; return end
end

function map:parse(map)
	if type(map) == "string" then
		for line in map:gmatch("[^\r\n]+") do
			self:parseline(line)
		end
	elseif type(map) == "userdata" then
		for line in map:lines() do
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