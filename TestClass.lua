return class "User" {
    User = function(self, args)
        self.id = args.id
        self.firstName = args.firstName
        self.lastName = args.lastName
        self.login = args.login
        self.email = args.email
        self.birthDate = args.birthDate
        self.lastSeen = args.lastSeen
        self.gender = args.gender
    end;


    public = {
        static = {};

        getName = function(self) return self.name end;

        setName = function(self, value) self.name = value end;

        getFirstName = function(self) return self.firstName end;

        setFirstName = function(self, value) self.firstName = value end;

        getLastName = function(self) return self.lastName end;

        setLastName = function(self, value) self.lastName = value end;

        getLogin = function(self) return self.login end;

        setLogin = function(self, value) self.login = value end;

        getEmail = function(self) return self.email end;

        setEmail = function(self, value) self.email = value end;

        getBirthDate = function(self) return self.birthDate end;

        setBirthDate = function(self, value) self.birthDate = value end;

        getLastSeen = function(self) return self.lastSeen end;

        setLastSeen = function(self, value) self.lastSeen = value end;

        getGender = function(self) return self.gender end;

        setGender = function(self, value) self.gender = value end;
    };

    private = {
        static = {};

        id = null();
        firstName = null();
        lastName = null();
        login = null();
        email = null();
        birthDate = null();
        lastSeen = null();
        gender = null();

    };
}