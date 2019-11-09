--[[
  Class: unitTest 
  Defines a unitTest
    
  Properties:
    (function) test
    (LuaNumber) testNum
]]
-- Imports
local common = require("../constants/common")
local oop = require("../helpers/oop")

-- This
local unitTest = {}
unitTest.prototype = {}
unitTest.prototype.TotalTests = {0} -- Static class variable.
unitTest.prototype.test = common.FNC_ALWAYS_TRUE
unitTest.prototype.testNum = 0
unitTest.prototype.type = "unitTest" -- Extension of type(o), use (type(o)=="table" and o.type=="unitTest")

--[[
  Constructor: unitTest
  Sets the testNum to the latest test number.
]]
function unitTest.constructor (newObject)
  newObject.TotalTests[1] = newObject.TotalTests[1] + 1
  newObject.testNum = newObject.TotalTests[1]
end

--[[
  Method: run
  Runs the unit test.
    
  Arguments:
    none

  Returns: true if success, false if not.
]]
function unitTest:run ()
  -- Try/catch block for the test.
  local status, err = pcall(self.test)
  if (type(err) == "string" or err == false) then
    -- If something went wrong. Let the end-user know.
    -- print(string.format(common.FMT_ERR_TEST_FAILED, self.testNum, tostring(err)))
    return false, err
  end

  return true
end

-- Turn unitTest into a proper class.
oop.defineClass(unitTest)

return unitTest
