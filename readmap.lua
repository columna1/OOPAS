local map = {}
local prefile = {}

map.currentPos = 0

function prefile.new()
	local self = {}
	setmetatable(self,{__index = m})
	return self
end

return prefile