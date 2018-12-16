local operations = {
	__add = function(t1,t2)
		if type(t1) == "number" then t1 = vec2(t1,t1) end
		if type(t2) == "number" then t2 = vec2(t2,t2) end
		return vec2(t1[1]+t2[1],t1[2]+t2[2])
	end,
	__sub = function(t1,t2)
		if type(t1) == "number" then t1 = vec2(t1,t1) end
		if type(t2) == "number" then t2 = vec2(t2,t2) end
		return vec2(t1[1]-t2[1],t1[2]-t2[2])
	end,
	__mul = function(t1,t2)
		if type(t1) == "number" then t1 = vec2(t1,t1) end
		if type(t2) == "number" then t2 = vec2(t2,t2) end
		return vec2(t1[1]*t2[1],t1[2]*t2[2])
	end,
	__div = function(t1,t2)
		if type(t1) == "number" then t1 = vec2(t1,t1) end
		if type(t2) == "number" then t2 = vec2(t2,t2) end
		return vec2(t1[1]/t2[1],t1[2]/t2[2])
	end,
	__eq = function(t1,t2)
		if type(t1) == "table" and type(t2) == "table" then
			return t1[1] == t2[1] and t1[2] == t2[2]
		end
	end,
	__index = function(t,k)
		for i,n in pairs(vector2ExtraOperationsTable) do
			if k == i then
				return n(t)
			end
		end
	end
}

local function getLength(a,b)
	return math.sqrt((a*a)+(b*b))
end
vector2ExtraOperationsTable = {}
vector2ExtraOperationsTable.length = function(t) return getLength(t[1],t[2]) end
vector2ExtraOperationsTable.lengthSquared = function(t) return getLength(t[1],t[2])^2 end
vector2ExtraOperationsTable.normalize = function(t) return t/getLength(t[1],t[2]) end
vector2ExtraOperationsTable.print = function(t) print(t[1],t[2]) end
vector2ExtraOperationsTable.X = function(t) return t[1] end
vector2ExtraOperationsTable.Y = function(t) return t[2] end
vector2ExtraOperationsTable.x = function(t) return t[1] end
vector2ExtraOperationsTable.y = function(t) return t[2] end

function vec2(a,b)
	if type(a) == "table" and b == nil then
		b = a[2]
		a = a[1]
	end
	a = a and a or 0
	b = b and b or 0
	local r = {a,b}
	setmetatable(r,operations)
	return r
end
return vec2