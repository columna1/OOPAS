--[[
  Class: unitTestRunner
  Runs unitTests
    
  Properties:
    (unitTest[]) unitTests
]]

-- Imports
local unitTest = require("../unitTests/unitTest")

-- This
local unitTestRunner = {}

-- Prototype
unitTestRunner.prototype = {}
unitTestRunner.prototype.testsFailed = 0
unitTestRunner.prototype.testsPassed = 0
unitTestRunner.prototype.unitTests = {}

function unitTestRunner.addTest (testFunc)

end