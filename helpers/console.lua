--[[
  Static Class: console
  Helps manage console related operations. Such as color coding and output.
    
  Methods:

]]
local console = {}

--[[
  Method: print
  Prints information to the console using string.format.
    
  Arguments:
    (string) format,
    (vararg) variables
]]
function console.print (format, ...)
  print(format:format(...))
end

return console