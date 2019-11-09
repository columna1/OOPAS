--[[
  Class: unitTestResult
  Holds information regarding a unitTest.
    
  Properties:
    (unitTest*) unitTest
    (bool) passed
    (string?) errorMessage
    (LuaNumber) testDuration
]]

-- Imports
local common = require("../constants/common")
local oop = require("../helpers/oop")

-- This
local unitTestResult = {}

unitTestResult.prototype = {}
unitTestResult.prototype.unitTest = common.NULL_OBJECT
unitTestResult.prototype.passed = false
unitTestResult.prototype.errorMessage = ""
unitTestResult.prototype.testDuration = 0

oop.defineClass(unitTestResult)

return unitTestResult