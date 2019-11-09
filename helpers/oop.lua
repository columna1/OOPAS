--[[
    Object Oriented Programming for Lua
]]--

local oop = {}

--[[
    Method: defineClass
    Creates a constructor for tab based on its properties.
    The new object will:
        1. Inherit values from the prototype property of the class object, then
        2. Inherit values from the options specified, then
        3. Inherit any class methods from tab, then
        4. Inherit the metatable of the class if it exists, finally
        5. Run the tab.constructor method if it exists.

    Arguments: (Class) tab
    Returns: (object) newObject
]]
function oop.defineClass (tab)
    -- Set tab.new to
    tab.new = function (options)
        -- First, define the new object inheriting from tab.
        local newObject = {}

        -- Then, inherit the prototype values.
        if (type(tab.prototype) == "table") then
            for key, value in pairs(tab.prototype) do
                newObject[key] = value
            end
        end

        -- Then, override any prototype values with the options specified.
        if (type(options) == "table") then
            for key, value in pairs(options) do
                newObject[key] = value
            end
        end

        -- Then, add any class methods from tab.
        for key, value in pairs(tab) do
            if (type(value) == "function") then
                newObject[key] = value
            end
        end

        -- Then, inherit the metatable if it exists.
        if (type(tab.metatable) == "table") then
            setmetatable(newObject, tab.metatable)
        end

        -- Finally, run the constructor if it exists.
        if (type(tab.constructor) == "function") then
            tab.constructor(newObject)
        end

        return newObject
    end
end

return oop
