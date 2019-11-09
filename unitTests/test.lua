-- Imports
local unitTestRunner = require("../unitTests/unitTestRunner")

local TestRunner = unitTestRunner.new()

-- Add unit tests.
TestRunner:addTests(require("../unitTests/vec2"))

TestRunner:runTests()
TestRunner:displayResults()

print("Press enter to exit.")
io.read()