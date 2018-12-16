local m = {}

m.file = ""

function m.readBytes(x)--read x num of bytes and return as string
	if not m.file or type(m.file) == "string" then
		error("no file to read from")
	else
		return m.file:read(x)
	end
end

function m.readByte()--read and return a number
	return string.byte(m.readBytes(1))
end

function m.readNumber(x)--little endian
	local sum = 0
	for i = 0,x-1 do
		sum = sum + bit.lshift(m.readByte(),8*i)
	end
	return sum
end

function m.readLong()--little endian
	return m.readNumber(8)
end

function m.readInt()--little endian
	return m.readNumber(4)
end

function m.readShort()--little endian
	return m.readNumber(2)
end

function m.readBool() return not(m.readByte()==0) end

function m.readULEB128()--read the variable length values
 local c; --used to tell weather or not to read another byte
 local value = m.readByte()--get the first byte
 if  math.floor(value / 2 ^ 7) == 1 then--does a binary right shift by 7 to see if the last bit is on (aka continue reading the number)
  value = value - 128--negate that last bit
  repeat
   local c1 = m.readByte()--get the next byte
   c = math.floor( c1 / 2 ^ 7)--find out if the number continues the next byte
   if c == 1 then c1 = c1 -128 end--if it does negate the last byte
   value = c1 * 2 ^ 7 + value--shift the current number to the left by 7 bits and then add the next byte
  until c == 0--repeat if there is more to the value
 end
 return value
end

function m.readString()
	--see if first byte is 0b if not then don't read
	if m.readByte() == 0x0b then
		return(m.readBytes(m.readULEB128()))
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
function m.readDouble() return doubleDecode(m.readBytes(8)) end

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

function m.readSingle() return singleDecode(m.readBytes(4)) end

return m