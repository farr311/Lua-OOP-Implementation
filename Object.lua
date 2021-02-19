--[[
    * Object class is the parent class for everything in ZLua
    * It has all the basic properties and methods of an instance in 
    * the object oriented model
    * Object provides methods for instantiation, inheritance, encapsulation
    * and basic polymorphism, as well as Type system be overriding standard
    * Lua type() method
]]

--[[@TEMP]]
local NotATypeObjectError = function() error("Not a TypeObject", 2) end
local AccessError = function(t)
    if t == "protected" then
        return error("Attemp to access a protected field by a class that is not a ", 2)
    end
end

local Object = {
    static = {
        init = function(self, args)
           --[[
                * Initialize static fields outside of constructor and before
                * it has been invoked
            ]]

          --  self._.initializedStatic = true
        end,
    },
    init = function(self, args)
       --[[
            * Initialize instance fields outside of constructor and before
            * it has been invoked
        ]]
        setmetatable(self.protected, {
            __index = function(t, k) 
                if t:instanceof(self) then
                    return self.protected[k]
                else
                    return AccessError("protected")
                end
            end
        })
    end,
    public = {},
    private = {},
    protected = {},
    constructor = function(self, args)
        if not self._.initializedStatic then
            self.static:init()
        end

        self:init()

        local instance = {}
        setmetatable(instance, { __index = function(t, k)
            if k == "_" then
                return nil
            else
                return self[k]
            end
        end })


        return instance
    end,
    _ = {
        parentClass = nil,
        initializedStatic = false,
        type = "Object",
        instanceArgs = {};
        setInsanceArgs = function(self, args)
            self.instanceArgs[#self.instanceArgs + 1] = args
        end
    }
}


--[[
    * Make Object.static:init() always receive Object as the first arg as
    * opposed to Object.static
]]
setmetatable(Object.static, {
    __index = function(t, k)
        print("THERE", k)
        if k == "init" then
            return function(s, args) print(s) return Object.static:init(args) end
        end
    end
})

local function validateTypeObject(typeObject)
    --[[
        * Checks if passed object is in fact a type object with all
        * the nessesery fields initialized
    ]]

    if typeObject == Object then
        --[[ if type(typeObject.constructor) == "function" then

        end ]]

        return true
    end
end

_G.class = function()
    return {
        extends = function(self, typeObject)
            self = typeObject
            self.super = typeObject
            return self
        end
    }
end
 
_G.new = function(typeObject)
    local modifierHandler = function(t, k)
        if t.public[k] then return t.public[k] end
        if t.private[k] then return AccessError("private") end
        if t.protected[k] then return AccessError("protected") end
        return nil
    end

    if validateTypeObject(typeObject) then
        local instance
        local parentInstance
        
        --[[
            * If the passed type extends another type, the root predessecor
            * must be initialized first
        ]]
        if typeObject._.parentClass then
            parentInstance = new(typeObject._.parentClass)
        else
            parentInstance = Object:constructor(typeObject._.instanceArgs[#typeObject._.instanceArgs])
        end

        instance = typeObject:constructor(typeObject._.instanceArgs[#typeObject._.instanceArgs])

        if not (instance == parentInstance) then
            if not (type(instance.instanceof) == "function") then
                setmetatable(instance, { 
                    __index = function(t, k)
                        local value = modifierHandler(t, k)
                        return value == nil and parentInstance[k] or value
                    end
                })
            end
        else
            setmetatable(instance, { __index = modifierHandler })
        end

        return instance
    else
        return NotATypeObjectError()
    end
end

--[[
    * Inhanced type system allows simpler access to more detailed information
    * about the object at runtime
]]
local luaType = type
type = function(o)
    if luaType(o) == "table" then
        if o._ and o._.type then
            return o._.type
        else
            return "table"
        end
    else
       return luaType(o) 
    end
end

setmetatable(Object, {
    __call = function(self, args)
        self._:setInsanceArgs(args)
        return self
    end
})

return Object