--[[
    Module: common
    Common Values in this project.
]]
local common = {}

-- Error formats.
common.FMT_ERR_UNEXPECTED_KEY = "Unexpected key type: '%s' (%s)"

-- Common functions.
--[[
  Method: common.FNC_BLANK
  Does nothing.
    
  Arguments:
    nothing.

  Returns: nothing.
]]
function common.FNC_BLANK ()
end

--[[
  Method: common.FNC_ALWAYS_FALSE
  Is always false.
    
  Arguments:
    nothing

  Returns: false
]]
function common.FNC_ALWAYS_FALSE ()
    return false
end

--[[
  Method: common.FNC_ALWAYS_TRUE
  Is always true.
    
  Arguments:
    nothing

  Returns: true
]]
function common.FNC_ALWAYS_TRUE ()
    return true
end

-- Tostring formats for class objects.
common.FMT_STR_VEC2 = "%s\t%s"

return common