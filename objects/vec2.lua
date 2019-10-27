--[[
	Class: vec2
	Allows for easy operations between 2 numbers.

	Properties:
		(LuaNumber) x = 0 (also can be referenced as [1])
		(LuaNumber) y = 0 (also can be referenced as [2])
]]

-- Imports
local common = require("common")
local oop = require("oop")

-- This
local vec2 = {}

--[[
	vec2 Prototype
]]
vec2.prototype = {}
vec2.prototype.type = "vec2" -- Extension of type(o), use (type(o)=="table" and o.type=="vec2")
vec2.prototype.x = 0
vec2.prototype.y = 0

-- Metatable object.
vec2.metatable = {}

--[[
	Metamethod: vec2.metatable.__add
	Adds two vec2 instances together.

	Arguments:
		(vec2) a
		(vec2) b

	Returns: (vec2) a+b
]]
function vec2.metatable.__add (a, b)
	-- Ensure a and b are vec2 instances.
	if (type(a) ~= "table" or a.type ~= "vec2") then
		a = vec2.new(a, a)
	end

	if (type(b) ~= "table" or b.type ~= "vec2") then
		b = vec2.new(b, b)
	end

	return vec2.new(a.x + b.x, a.y + b.y)
end

--[[
	Metamethod: vec2.metatable.__sub
	Subtracts a vec2 instance from another.

	Arguments:
		(vec2) a
		(vec2) b

	Returns: (vec2) a-b
]]
function vec2.metatable.__sub (a, b)
	-- Ensure a and b are vec2 instances.
	if (type(a) ~= "table" or a.type ~= "vec2") then
		a = vec2.new(a, a)
	end

	if (type(b) ~= "table" or b.type ~= "vec2") then
		b = vec2.new(b, b)
	end

	return vec2.new(a.x - b.x, a.y - b.y)
end

--[[
	Metamethod: vec2.metatable.__mul
	Multiplies two vec2 instances together.

	Arguments:
		(vec2) a
		(vec2) b

	Returns: (vec2) a*b
]]
function vec2.metatable.__mul (a, b)
	-- Ensure a and b are vec2 instances.
	if (type(a) ~= "table" or a.type ~= "vec2") then
		a = vec2.new(a, a)
	end

	if (type(b) ~= "table" or b.type ~= "vec2") then
		b = vec2.new(b, b)
	end

	return vec2.new(a.x * b.x, a.y * b.y)
end

--[[
	Metamethod: vec2.metatable.__div
	Multiplies two vec2 instances together.

	Arguments:
		(vec2) a
		(vec2) b

	Returns: (vec2) a*b
]]
function vec2.metatable.__div (a, b)
	-- Ensure a and b are vec2 instances.
	if (type(a) ~= "table" or a.type ~= "vec2") then
		a = vec2.new(a, a)
	end

	if (type(b) ~= "table" or b.type ~= "vec2") then
		b = vec2.new(b, b)
	end

	return vec2.new(a.x / b.x, a.y / b.y)
end

--[[
	Metamethod: vec2.metatable.__index
	Fetches a property of a vec2 instance.

	Arguments:
		(vec2) tab
		(object) key

	Returns: (object) value

	Throws: Unexpected Key Type if the key provided isn't a string or a LuaNumber.
]]
function vec2.metatable.__index (tab, key)
	if (type(key) == "number") then
		-- We want .x and .y to also be referencable through [1] and [2].
		if (key == 1) then
			return self.x
		elseif (key == 2) then
			return self.y
		end
		
		-- Explicitly stating that nil will be returned.
		return nil
	elseif (type(key) == "string") then
		-- Otherwise, operate as normal.
		return tab[key]
	else
		-- Not sure if someone can *Try* to pass other types through index, but they might.
		error(string.format(common.FMT_ERR_UNEXPECTED_KEY, type(key), tostring(key)))
	end
end

--[[
	Metamethod: vec2.metatable.__tostring
	Converts the vec2 to a string.

	Arguments:
		(vec2) tab

	Returns: (string) output
]]
function vec2.metatable.__tostring (tab)
	return string.format(common.FMT_VEC2, tab.x, tab.y)
end

--[[
	Method: getLength
	Gets Pythagorean's theorem for distance using the x and y properties of the vec2.

	Arguments: (none)
	Returns: (LuaNumber) dist 
]]
function vec2:getLength ()
	return (self.x^2 + self.y^2)^0.5
end

--[[
	Method: getLengthSquared
	Same as getLength, except the end result isn't square rooted.

	Arguments: (none)
	Returns: (LuaNumber) distSquared
]]
function vec2:getLengthSquared ()
	return (self.x^2 + self.y^2)
end

--[[
	Method: normalize
	Divides x and y by the value returned by getLength, and creates
	a new vec2 from the result.

	Arguments: (none)
	Returns: (vec2) normalizedVec2
]]
function vec2:normalize ()
	-- Define local variables.
	local x1, y1 = self.x, self.y
	local x2 = self:getLength()
	local y2 = x2
	local x3 = self.x / x2
	local y3 = self.y / y2
	
	-- Create a new vec2 using what we calculated.
	return vec2.new(x3, y3)
end

--[[
	Method: print
	Prints out the tostring version of the vec2.

	Arguments: (none)
	Returns: nil
]]
function vec2:print ()
	print(tostring(self))
end

-- Convert vec2 to a proper class.
oop.defineClass(vec2)

return vec2
