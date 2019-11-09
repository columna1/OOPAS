--[[
  Unit tests for the vec2 class.
]]

-- Imports
local vec2 = require("../objects/vec2")
local unitTest = require("../unitTests/unitTest")

local tests = {}

--[[
  Test: nilVec2
  Tests to see if vec2 was imported properly.
]]
function tests.nilVec2 ()
  assert(type(vec2) ~= "nil", "vec2 import failed!")
end

return tests
