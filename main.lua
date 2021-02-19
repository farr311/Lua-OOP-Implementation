local Object = require("Object")

--Creating an instance of an Object class
local instance = new(Object)
print(instance) --table

--Creating class Person that is a child class of the Object
local Person = class():extends(Object)

--Defining non-default constructor for the Person class
function Person:constructor(args)
    local instance = self.super(args) --Invoking parent class constructor

    instance.public.name = args.name
    instance.public.age = args.age
    instance.private.lol = args.age .. args.age

    return instance
end

--Instantiating the Person class
local i2 = new(    Person{ name = "John", age = 20 }               )

print(i2) --table
print(i2.public.name) --John
print(i2.public.age) --20
print(i2.name) --John
print(i2.age) --20

print(i2.private.lol) --2020
print(i2.lol) --nil




--[[ for k, v in pairs(i2) do 
    print(k, v)

    if k == "public" then
        for s, d in pairs(v) do
            print("   ", s , d)
        end
    end
end ]]

















--[[ local new = function( class )
    if type( class ) == "string" then
        print("STRING PASSSED")
    else
        return class:construct()
    end
end

local MyClass = {}

function MyClass:construct()
    print("*********************************")
    print("class has been constructed")
end

--[[ new(MyClass)
new( "test" )
local class = new "tt" ]]
--local class = new MyClass

--[[ setmetatable(_G, { __newindex = function(self, k, v) rawset(self, k, v) print(self, k, v)  end})

function extends(str)
    return require(str)
end

local t1 = require("t1")
local t = t1:new() ]]


--[[ for k, v in pairs(t) do 
    print(k, v)
end ]]

--[[ print(t.public.name) ]]