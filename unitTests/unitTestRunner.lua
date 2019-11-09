--[[
  Class: unitTestRunner
  Runs unitTests

  Methods:
    (void) addTest ((function) testFunc) - Adds a new unit test.
    (void) addTests ((function[]) testFuncs) - Adds a new group of unit tests.
    (void) displayResults () - Displays results from runTests.
    (void) runTests () - Runs all tests in the pool and summarizes the results.
    
  Properties:
    (unitTest[]) unitTests
    (unitTestResult[]) unitTestResults
]]

-- Imports
local common = require("../constants/common")
local console = require("../helpers/console")
local oop = require("../helpers/oop")
local unitTest = require("../unitTests/unitTest")
local unitTestResult = require("../unitTests/unitTestResult")

-- This
local unitTestRunner = {}

-- Prototype
unitTestRunner.prototype = {}
unitTestRunner.prototype.testsFailed = 0
unitTestRunner.prototype.testsPassed = 0
unitTestRunner.prototype.unitTests = common.NULL_OBJECT
unitTestRunner.prototype.unitTestResults = common.NULL_OBJECT
unitTestRunner.prototype.type = "unitTestRunner"

--[[
  Constructor: unitTestRunner
  Ensures that unitTests and unitTestResults point to a unique table.
]]
function unitTestRunner.constructor (newObject)
  newObject.unitTests = {}
  newObject.unitTestResults = {}
end

local function percentage_format (value)
  return math.floor((value * 100) + 0.5)
end

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
  Method: addTests
  Adds an array of tests.
    
  Arguments:
    (function[]) testFuncs
]]
function unitTestRunner:addTests (testFuncs)
  for key, value in pairs(testFuncs) do
    self:addTest(value)
  end
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
  Method: displayResults
  Displays the results.
]]
function unitTestRunner:displayResults ()
  if (self.testsFailed == 0) then
    print("All tests passed!")
  else
    -- Display # of tests passed
    console.print(common.FMT_TESTS_PASSED, 
      self.testsPassed, 
      #self.unitTests, 
      percentage_format(self.testsPassed / #self.unitTests))

    -- Display # of tests failed
    console.print(common.FMT_TESTS_FAILED,
      self.testsFailed,
      #self.unitTests,
      percentage_format(self.testsFailed / #self.unitTests))

    -- Display every error message
    print("Error Messages: ")
    for k, testResult in pairs(self.unitTestResults) do
      if (testResult.passed == false) then
        console.print(common.FMT_TEST_RESULT, 
          testResult.unitTest.testNum,
          testResult.errorMessage)
      end
    end
  end
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