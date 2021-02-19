# Lua-OOP-Implementation
 
This project has a single goal to implement an object oriented mechanisms in a clear and and clean way using pure Lua 5.1 and its standard metatable system.
As the project progresses, all of the main conceptions of the OOP paradigm will be implemented one by one, including inheritance, encapsulation and polymorphism

# Achievements so far

A rather clean inheritance mechanism was implemented. It allows declaring classes and creating objectes by instantiating them but the most advanced feature of this mechanism is the ability to extend on class with another and inherit the functionality of the predessecor class. Also the first steps towards data hiding mechaisms are made.

# Future Roadmap

### 1. Inhertiance

There's still a lot to be done one the side of inheritance. First of, in the next versions an alternative mechanism for declaring classes will be added. This mechanism will allow defining classes in the C#/Java-esq way with all of the fields and methods defined between curly braces. Also the current state of the project requires a lot of cleaning and refactoring.

### 2. Encapsulation

There's not a lot to be done about encapsilation in the project, since Lua developers have already provided the community with all of the nessesery mechanisms of bindning objects and their data by introdcuing the allmighty Lua tables. However one of the features that a lot of true OOP languages have, such as Java, is data hiding. This mechanism can be implemented and in fact a lot of the nessesery steps on the way to implementing it, are already made. When this project will be complete, there will be 3 access modifiers: 
- public
- private
- protected
This modifiers will be implemented using metatables and __index metamethod.

### 3. Polymorphism

Being the main prinicple of the OOP paradigm, polymorphism creates ceratin obstacles on the way to implementing it. Lua is dynamically typed, which exclude any possibilities of static Polymorphism, however some of the dynamic polymorphism features could be done, such as runtime type cheking that treats instances of the subtype as instances of the type. The first steps are also made here, since the object:instanceof(typeObject) has been implented.