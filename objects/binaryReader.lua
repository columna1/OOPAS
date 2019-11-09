--[[
  Class: binaryReader
  Reads binary information from a file.
    
  Methods:


  Properties:

]]
-- Constants
local ERR_CLOSE_ALREADY = "IOException: The stream is already closed."
local ERR_CLOSE_NONSTREAM = "IOException: Cannot close a non-fileStream."
local ERR_CONST_ARGEXC = "ArgumentException: Expected File or string."
local ERR_CONST_EMPTY_STR = "ArgumentException: String must be longer than 0 characters."
local ERR_READ_CLOSED = "IOException: Cannot read a closed stream."

-- Imports
local common = require("../constants/common")
local oop = require("../helpers/oop")

-- This
local binaryReader = {}
binaryReader.prototype = {}
binaryReader.prototype.isClosed = false
binaryReader.prototype.isFileStream = false
binaryReader.prototype.position = 0
binaryReader.prototype.stream = common.NULL_OBJECT

--[[
  Constructor: binaryReader
  Ensures that the stream passed is a proper file stream or a string.
]]
function binaryReader.constructor (newObject)
  local type_stream = type(newObject.stream)
  if (type_stream == "string") then
    -- Cannot read data from an empty string.
    assert(#newObject.stream > 0, ERR_CONST_EMPTY_STR)
  elseif (type_stream == "userdata") then
    -- Cannot read data from a non-file object.
    assert(newObject.stream.read ~= nil, ERR_CONST_ARGEXC)
    newObject.isFileStream = true
  else
    -- Improper type was passed.
    error(ERR_CONST_ARGEXC)
  end
end

--[[
  Method: close
  Closes the file stream.

  Throws:
    (IOException) Not a valid file stream (is it a string?)
    (IOException) Stream is already closed.
]]
function binaryReader:close ()
  assert(self.isFileStream, ERR_CLOSE_NONSTREAM)
  assert(not self.isClosed, ERR_CLOSE_ALREADY)

  self.stream:close()
end

--[[
  Method: readBytes
  Reads a number of bytes from the stream.
    
  Arguments:
    (LuaNumber) numBytes

  Returns: (LuaNumber[]) data

  Throws:
    (IOException) Cannot read from a closed stream.
]]
function binaryReader:readBytes (numBytes)
  assert(not self.isClosed, ERR_READ_CLOSED)
  local data = common.NULL_OBJECT

  if (self.isFileStream) then
    data = self.stream:read(numBytes)
  else
    data = self.stream:sub(self.position, self.position + numBytes)
  end

  self.position = self.position + numBytes
  return data
end

--[[
  Method: readByte
  Reads a single byte.

  Returns: (LuaNumber) byte
]]
function binaryReader:readByte ()
  return self.readBytes(1)[1]
end

--[[
  Method: readBoolean
  Reads a boolean.

  Returns: (boolean) result
]]
function binaryReader:readBoolean ()
  return (self:readByte() ~= 0)
end

--[[
  Method: readLong
  Reads a long.

  Returns: (LuaNumber) long
]]
function binaryReader:readLong ()
  local data = self:readBytes(8)
  local total = 0
  for i=1, 8 do
    total = total + bit.lshift(data[i], 8*i)
  end
  return total
end

--[[
  Method: readInt
  Reads an int.

  Returns: (LuaNumber) int
]]
function binaryReader:readInt ()
  local data = self:readBytes(4)
  local total = 0
  for i=1, 4 do
    total = total + bit.lshift(data[i], 8*i)
  end
  return total
end

--[[
  Method: readShort
  Reads a short.

  Returns: (LuaNumber) short
]]
function binaryReader:readShort ()
  local data = self:readBytes(2)
  local total = 0
  for i=1, 2 do
    total = total + bit.lshift(data[i], 8*i)
  end
  return total
end

--[[
  Method: readULEB128
  Reads a variable-length value (VLQ).

  Returns: (LuaNumber) ULEB128
]]
function binaryReader:readULEB128()
	local c = 0 -- Used to tell whether or not to read another byte.
	local value = self:readByte() -- Get the first byte
	if math.floor(value / 2 ^ 7) == 1 then -- Does a binary right shift by 7 to see if the last bit is on (aka continue reading the number)
		value = value - 128 -- Negate that last bit
		repeat
			local c1 = self:readByte()      -- Get the next byte
			c = math.floor( c1 / 2 ^ 7)     -- Find out if the number continues the next byte
			if c == 1 then c1 = c1 -128 end -- If it does negate the last byte
			value = c1 * 2 ^ 7 + value      -- Shift the current number to the left by 7 bits and then add the next byte
		until c == 0                      -- Repeat if there is more to the value
	end
	return value
end

return binaryReader