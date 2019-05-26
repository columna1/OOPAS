local m = {}
local bin = {}

m.file = ""
m.type = ""
m.pos = 0

local function check(a)
	if type(a) ~= "table" then
		error("expected table, got: "..type(a))
	end
end

function m:readBytes(x)--read x num of bytes and return as string
	check(self)
	if type(self.file) == "string" then
		if self.pos > #self.file-1 then
			return nil
		end
		local p = self.pos
		self.pos = self.pos + x
		return self.file:sub(p+1,self.pos)
	elseif type(self.file) == "userdata" then
		return self.file:read(x)
	else
		error("no file to read from (how did you do that!?)")
	end
end

function m:readByte()--read and return a number
	check(self)
	return string.byte(self:readBytes(1))
end

function m:readNumber(x)--little endian
	check(self)
	local sum = 0
	for i = 0,x-1 do
		sum = sum + bit.lshift(self:readByte(),8*i)
	end
	return sum
end

function m:readLong()--little endian --note this won't work correctly as lua's number system is a 32/64 bit float depending
--on the host's architecture, as such you don't get as much accuracy, something like 56 bit on 64bit machines which is not enough
	check(self)
	return self:readNumber(8)
end

function m:readInt()--little endian
	check(self)
	return self:readNumber(4)
end

function m:readShort()--little endian
	check(self)
	return self:readNumber(2)
end

function m:readBool()
	check(self)
	return not(self:readByte()==0) 
end

function m:readULEB128()--read the variable length values
	check(self)
	local c; --used to tell weather or not to read another byte
	local value = self:readByte()--get the first byte
	if  math.floor(value / 2 ^ 7) == 1 then--does a binary right shift by 7 to see if the last bit is on (aka continue reading the number)
		value = value - 128--negate that last bit
		repeat
			local c1 = self:readByte()--get the next byte
			c = math.floor( c1 / 2 ^ 7)--find out if the number continues the next byte
			if c == 1 then c1 = c1 -128 end--if it does negate the last byte
			value = c1 * 2 ^ 7 + value--shift the current number to the left by 7 bits and then add the next byte
		until c == 0--repeat if there is more to the value
	end
	return value
end

function m:readString()
	check(self)
	--see if first byte is 0b if not then don't read
	if self:readByte() == 0x0b then
		return(self:readBytes(self:readULEB128()))
	else
		return ""
	end
end

local function doubleDecode(x) --8 byte little endian string to number
  local sign = 1
  local mantissa = string.byte(x, 7) % 16
  for i = 6, 1, -1 do mantissa = mantissa * 256 + string.byte(x, i) end
  if string.byte(x, 8) > 127 then sign = -1 end
  local exponent = (string.byte(x, 8) % 128) * 16 +
                   math.floor(string.byte(x, 7) / 16)
  if exponent == 0 then return 0 end
  mantissa = (math.ldexp(mantissa, -52) + 1) * sign
  return math.ldexp(mantissa, exponent - 1023)
end
function m:readDouble()
	check(self)
	return doubleDecode(self:readBytes(8)) 
end

local function singleDecode(x)
  local sign = 1
  local mantissa = string.byte(x, 3) % 128
  for i = 2, 1, -1 do mantissa = mantissa * 256 + string.byte(x, i) end
  if string.byte(x, 4) > 127 then sign = -1 end
  local exponent = (string.byte(x, 4) % 128) * 2 +
                   math.floor(string.byte(x, 3) / 128)
  if exponent == 0 then return 0 end
  mantissa = (math.ldexp(mantissa, -23) + 1) * sign
  return math.ldexp(mantissa, exponent - 127)
end

function m:readSingle()
	check(self)
	return singleDecode(self:readBytes(4))
end

function m:close()
	if type(self.file) == "userdata" then
		self.file:close()
	end
end

function bin.new(file)
	local self = {}
	setmetatable(self,{__index = m})
	self.file = file
	if type(file) == "string" then
		--user probably provided raw data in a string
		if #file > 0 then
			self.file = file
		else
			return nil,"string data must be longer than 0 chars"
		end
	elseif type(file) == "userdata" then
		--user provided a file
		if file.read then--this won't check read/write permissions*
			self.file = file
		else
			return nil,"expecting file object or string"
		end
	else
		return nil,"expecting file object or string"
	end
	return self
end

return bin