--[[
  Class: unitTestRunner
  Runs unitTests

  Methods:
    (void) addTest ((function) testFunc) - Adds a new unit test.
    (void) runTests () - Runs all tests in the pool and summarizes the results.
    
  Properties:
    (unitTest[]) unitTests
    (unitTestResult[]) unitTestResults
]]

-- Imports
local console = require("../helpers/console")
local unitTest = require("../unitTests/unitTest")
local unitTestResult = require("../unitTests/unitTestResult")

-- This
local unitTestRunner = {}

-- Prototype
unitTestRunner.prototype = {}
unitTestRunner.prototype.testsFailed = 0
unitTestRunner.prototype.testsPassed = 0
unitTestRunner.prototype.unitTests = {}
unitTestRunner.prototype.unitTestResults = {}

--[[
  Method: addTest 
  Adds a new unit test.
    
  Arguments:
    (function) testFunc
]]
function unitTestRunner:addTest (testFunc)
  local test = unitTest.new({
      test = testFunc
  })

  table.insert(self.unitTests, test)
end

--[[
  Method: addTestResult
  Adds a new unit test result.
    
  Arguments:
    (unitTest*) unitTest
    (bool) passed
    (LuaNumber) testDuration
    (string?) errorMessage
    
]]
function unitTestRunner:addTestResult (_unitTest, passed, testDuration, errorMessage)
  local testResult = unitTestResult.new({
    unitTest = _unitTest,
    passed = passed,
    testDuration = testDuration,
    errorMessage = errorMessage
  })

  table.insert(self.unitTestResults, testResult)
end

--[[
  Method: runTests
  Runs all tests in the pool.
]]
function unitTestRunner:runTests ()
  for i=1, #self.unitTests do
    local test = self.unitTests[i]

    -- t_start and t_end is so we can time the duration of the test.
    local t_start = os.clock()
    local pass, errorMessage = test:run() -- Run the test.
    local t_end = os.clock() - t_start
    
    if (type(errorMessage) ~= "string") then
      errorMessage = "" -- There's a possibility of a function returning a bad type.
    end

    self:addTestResult(test, pass, t_end, errorMessage)
    if (pass) then
      self.testsPassed = self.testsPassed + 1
    else
      self.testsFailed = self.testsFailed + 1
    end
  end
end

-- Turn unitTestRunner into a proper class.
oop.defineClass(unitTestRunner)

return unitTestRunner