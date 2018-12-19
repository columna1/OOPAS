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