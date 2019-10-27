--[[
    Object Oriented Programming for Lua
]]--

local oop = {}

--[[
    Method: defineClass
    Arguments: (Class) tab

    Creates a constructor for tab based on its properties.
    The new object will:
        1. Inherit values from the prototype property of the class object, then
        2. Inherit values from the options specified, then
        3. Inherit any class methods from tab, then finally
        4. Inherit the metatable of the class if it exists.
]]
function oop.defineClass (tab)
    -- Set tab.new to
    tab.new = function (self, options)
        -- First, define the new object inheriting from tab.
        local newObject = {}

        -- Then, inherit the prototype values.
        if (type(self.prototype) == "table") then
            for key, value in pairs(self.prototype) do
                newObject[key] = value
            end
        end

        -- Then, override any prototype values with the options specified.
        for key, value in options do
            newObject[key] = value
        end

        -- Then, add any class methods from tab.
        for key, value in pairs(tab) do
            if (type(value) == "function") then
                newObject[key] = value
            end
        end

        -- Finally, inherit the metatable if it exists.
        if (type(tab.metatable) == "table") then
            setmetatable(newObject, tab.metatable)
        end

        return newObject
    end
end

return oop
