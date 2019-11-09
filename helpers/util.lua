
--[[
	Method: string.split
	Splits a string by a separator.
		
	Arguments:
		(string) str
		(string) sep

	Returns: (string[]) strings
]]
function string.split (str,sep)
	if type(str)=="number" or type(str)=="boolean" then
		str = tostring(str) -- Convert the bad object to a string.
	elseif type(str)=="table" then
		error("Cannot split a table.") -- You cannot simply tostring a table. Besides, I doubt anyone would like to do this anyways.
	end
	local return_array = {} -- The return value.
	sep = sep or "%s" -- Lua space value is %s
	for Lstr_01 in string.gmatch(str, "([^"..sep.."]+)") do
		return_array[#return_array+1] = Lstr_01
	end
	return return_array
end

--[[
	Method: printTable
	Prints out a table.
		
	Arguments:
		(table) tabl
		(LuaNumber) wid = 1
]]
function printTable(tabl, wid)
	if not wid then wid = 1 end
	for i,v in pairs(tabl) do
		--if type(i) == "number" then if i >= 1000 then break end end
		if type(v) == "table" then
			print(string.rep(" ", wid * 3) .. i .. " = {")
			printTable(v, wid + 1)
			print(string.rep(" ", wid * 3) .. "}")
		elseif type(v) == "string" then
			print(string.rep(" ", wid * 3) .. i .. " = \"" .. v .. "\"")
		elseif type(v) == "number" then
			print(string.rep(" ", wid * 3) .. i .. " = " .. v)
			if v == nil then error("nan") end
		end 
	end 
end

--[[
	Method: round
	Rounds a number.
		
	Arguments:
		(LuaNumber) a

	Returns: (LuaNumber) rounded
]]
function round(a)
	a = a * 100
	a = a + 0.5
	return math.floor(a)/100
end

--[[
	Method: cull
	Creates a new table based on a condition.
	If not fun(tab[i]) then add it to the new table.
		
	Arguments:
		(table) tab
		(function) fun

	Example:
		local t = {1, 2, 3}
		local condition = function (x) return (x == 2) end
		local cull_t = cull(t, condition)

		-- cull_t[1] == 1
		-- cull_t[2] == 3

	Returns: (table) newtab
]]
function cull(tab,fun)
	local newtab = {}
	for i = 1,#tab do
		if not fun(tab[i]) then
			table.insert(newtab,tab[i])
		end
	end
	return newtab
end

--[[
	Method: average
	Calculates the average value from a table.
		
	Arguments:
		(LuaNumber[]) tab

	Returns: (LuaNumber) average
]]
function average(tab)
	local t = 0
	for i = 1,#tab do
		t = t + tab[i]
	end
	return math.floor(((t/#tab)*100)+0.5)/100
end

--[[
	Method: standardDeviation
	Calculates the standard deviation from a table.
		
	Arguments:
		(LuaNumber[]) tab

	Returns: (LuaNumber) standardDeviation
]]
function standardDeviation(tab)
	local t = 0
	for i = 1,#tab do
		t = t + tab[i]
	end
	local mean = t/#tab
	t = 0
	for i = 1,#tab do
		t = t + ((tab[i]-mean)^2)
	end
	t = t/#tab
	t = math.sqrt(t)
	return t
end
