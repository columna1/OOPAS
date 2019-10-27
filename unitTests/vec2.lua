-- Imports
local vec2 = require("../objects/vec2")
local unitTest = require("../unitTests/unitTest")

local tests = {}

--[[
  Test: nilVec2
  Tests to see if vec2 was imported properly.
    
  Arguments:
    

  Returns: 
]]
function tests.nilVec2 ()
  return (type(vec2) ~= "nil")
end
