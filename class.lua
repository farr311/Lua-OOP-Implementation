local Table = require("Table")
local ProtectedExecution = require("ProtectedExecution")

local function getFilename()
    local debugInfo = debug.getinfo(4)
    local fileSeparator = TEST_BUILD and package.config:sub(1,1) or "\\"
	local str = debugInfo.source:gsub(fileSeparator, "!"):gsub("-", "'"):gsub("%.lua", "")
	local tail = str:gsub(".*lua!src!.*", "")

    return str:gsub(tail, ""):gsub("'", "-"):gsub(".*!", "")
end

local classPaths = Table {}
local classNames = Table {}
local cachedClasses = Table {}

local nullValue = Table {}
local nullProto = nullValue.getPrototype()

for k, _ in pairs(nullProto) do
    nullProto[k] = nil
end
nullProto.__null = true

local luaPrint = print

local pack = function(...)
    return { n = select("#", ...), ... }
end

print = function(...)
    local args = pack(...)
    if args[1] == nullValue then
        return luaPrint("NULL")
    end

    return luaPrint(...)
end

function import(classPath)
    if not classPaths[fileName] then
        local fileName = classPath:gsub(".*/", "")

        classPaths:insert(classPath, fileName)
        classNames:insert(fileName, classPath:gsub("/", "."))
    end
end

function typeOf(obj)
    local rawType = type(obj)

    if rawType == "table" and type(obj.getClassName) == "function" then
        return obj:getClassName()
    end

    return rawType
end

function null() return nullValue end

local function deepCopy(t)
    local newTable = {}

    for k, v in pairs(t) do
        if type(v) == "table" then
            newTable[k] = deepCopy(v)
        end

        newTable[k] = v
    end

    return newTable
end

local Class = Table {
    new = function(self, className)
        local classInitializerObject = Table {
            initialize = function(self, classInitializer)
                classInitializer.public = classInitializer.public or {}
                classInitializer.private = classInitializer.private or {}
    
                classInitializer.public.static = classInitializer.public.static or Table {}
                classInitializer.private.static = classInitializer.private.static or Table {}
    
                local classObject = Table(classInitializer)
    
                local function createNewInstance()
                    local instanceObject = Table {}
                    instanceObject.private = Table(deepCopy(classInitializer.private))
                    instanceObject.public = Table(deepCopy(classInitializer.public))
    
                    local currentObjectPrototype = instanceObject:getPrototype()
                    currentObjectPrototype.type = function(self) return self:getClassName() end
                    currentObjectPrototype.getClassName = function(self) return className end
                    currentObjectPrototype.getClass = function(self) return classObject end
                    currentObjectPrototype.instanceOf = function(self, class)
                        if self.super and self.super.parentClasses then
                            for k, v in pairs(self.super.parentClasses) do
                                if type(class) == "string" and k == class then
                                    return true
                                end

                                if v == class then
                                    return true
                                end
                            end
                        end

                        if type(class) == "string" then
                            return self:getClassName() == class
                        end
    
                        return self:getClass() == class
                    end

                    instanceObject:setCustomIndex(function(t, k)
                        if k == className then
                            return error("AccessForbiddenException")
                        end
    
                        if k == "private" or instanceObject.private[k] or classInitializer.private.static[k] then
                            if className == getFilename() or "class" == getFilename() then
                                if k == "private" then
                                    return instanceObject.private
                                end
    
                                local value = instanceObject.private[k] or classInitializer.private.static[k]
    
                                if type(value) == "function" then
                                    return function(self, ...) return value(instanceObject, ...) end
                                end
    
                                return value
                            end
    
                            return error("AccessException: " .. className .. " " .. getFilename())
                        end

                        if instanceObject.public[k] ~= nil or classInitializer.public.static[k] ~= nil then
                            local value = instanceObject.public[k] or classInitializer.public.static[k]

                            if type(value) == "function" then
                                return function(self, ...) return value(instanceObject, ...) end
                            end
    
                            return value
                        end

                        if k ~= "super" then
                            if instanceObject.super then
                                for _, v in pairs(instanceObject.super.attachedInstances) do
                                    if v[k] then
                                        return v[k]
                                    end
                                end
                            end
                        end

                        return rawget(instanceObject, k) or classInitializer[k]
                    end)
    
                    instanceObject:setCustomNewIndex(function(t, k, v)
                        if rawget(instanceObject.private, k) ~= nil then
                            if className == getFilename() or "class" == getFilename() then
                                return rawset(instanceObject.private, k, v)
                            end
    
                            return error("AccessException: " .. className .. " " .. getFilename())
                        end

                        if rawget(instanceObject.private.static, k) ~= nil then
                            if className == getFilename() or "class" == getFilename() then
                                return rawset(instanceObject.private.static, k, v)
                            end
    
                            return error("AccessException: " .. className .. " " .. getFilename())
                        end

                        return rawset(instanceObject.public, k, v)
                    end)

                    return instanceObject
                end
    
                classObject:setCustomCall(function(t, ...) 
                    local instance = createNewInstance()
    
                    if classObject[className] then
                        classObject[className](instance, ...)
                        return instance
                    end

                    return error("UndefinedConstructorError")
                end)

                classObject:setCustomIndex(function(t, k)
                    if rawget(classInitializer, "public").static and rawget(classInitializer, "public").static[k] then
                        return rawget(classInitializer, "public").static[k]
                    end

                    if rawget(classInitializer, "private").static and rawget(classInitializer, "private").static[k] then
                        return rawget(classInitializer, "private").static[k]
                    end

                    return rawget(t, k)
                end)

                classObject:setCustomNewIndex(function(t, k, v)
                    if rawget(classInitializer, "public").static and rawget(classInitializer, "public").static[k] then
                        return rawset(classInitializer.public.static, k, v)
                    end

                    if rawget(classInitializer, "private").static and rawget(classInitializer, "private").static[k] then
                        return rawset(classInitializer.private.static, k, v)
                    end

                    return error("ClassAlterationError")
                end)

                classObject:getPrototype().className = className
                cachedClasses:insert(className, classObject)
    
                return classObject
            end;

            extend = function(self, parentClass, init)
                local function applyParentClass(self)
                    local currentObjectPrototype = self:getPrototype()
                    
                    if not currentObjectPrototype.super then
                        local parentObjectContainer = Table {
                            isSingleMode = true;
                            parentClasses = Table {
                                [parentClass.className] = parentClass
                            };
                            initializationSatatuses = Table {
                                [parentClass.className] = false
                            };
                            attachedInstances = Table {};
                            allInit = false;
                            uninitializedClasses = 1
                        }
                        
                        parentObjectContainer:setCustomCall(function(t, self, name, ...)
                            local k, v = next(parentObjectContainer.parentClasses)

                            if parentObjectContainer.allInit then
                                local parentObject = Table {}
                                parentObject:setCustomIndex(function(t, k)
                                    if name then
                                        return parentObjectContainer.attachedInstances[name][k]
                                    end

                                    if parentObjectContainer.isSingleMode then
                                        local _, v = next(parentObjectContainer.attachedInstances)
                                        return v[k]
                                    end

                                    return error("UndefinedParentAccessError")
                                end)

                                return parentObject
                            end

                            if name then
                                parentObjectContainer.initializationSatatuses[name] = true
                                parentObjectContainer.uninitializedClasses = parentObjectContainer.uninitializedClasses - 1
                                parentObjectContainer.allInit = parentObjectContainer.uninitializedClasses == 0
                                parentObjectContainer.attachedInstances:insert(name, parentObjectContainer.parentClasses[name](...))
                                return
                            end

                            parentObjectContainer.initializationSatatuses[k] = true
                            parentObjectContainer.allInit = true
                            parentObjectContainer.uninitializedClasses = 0
                            parentObjectContainer.attachedInstances:insert(name, v(...))
                        end)

                        currentObjectPrototype.super = parentObjectContainer
                    else
                        currentObjectPrototype.super.parentClasses:insert(parentClass.className, parentClass)
                        currentObjectPrototype.super.initializationSatatuses:insert(parentClass.className, false)
                        currentObjectPrototype.super.uninitializedClasses = currentObjectPrototype.super.uninitializedClasses + 1
                        currentObjectPrototype.super.isSingleMode = false
                    end

                    return self
                end
                
                if init then
                    return applyParentClass(self:initialize(init))
                end

                return function(initializer) return applyParentClass(self:initialize(initializer)) end
            end
        }

        classInitializerObject:setCustomCall(function(t, ...) 
            return classInitializerObject:initialize(...)
        end)

        classInitializerObject:setCustomIndex(function(t, k)
            if classNames[k] then
                local class = cachedClasses[k] or require(classNames[k])
                return function(self, initializer) return classInitializerObject:extend(class, initializer) end
            end

            return rawget(t, k)
        end)

        return classInitializerObject
    end;
}

Class:setCustomCall(function(t, name)
    local newClass = Class:new(name)
    newClass:getPrototype().className = name
    return newClass
end)

return Class