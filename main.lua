class = require("class")

local User = require("user")

local user = User{
    id = 1,
    firstName = "TestValue",
    lastName = "TestValue",
    login = "TestValue",
    email = "TestValue",
    birthDate = "TestValue",
    lastSeen = "TestValue",
    gender = "TestValue"
}

print(user.getFirstName())
print(user.getLastName())
print(user.getId())
print(user.setId(5))
print(user.getId())