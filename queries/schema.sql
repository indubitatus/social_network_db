CREATE TABLE Users (
    Phone_number BIGINT PRIMARY KEY,
    Surname TEXT NOT NULL,
    Name TEXT NOT NULL,
    Birthday DATE NOT NULL,
    Password TEXT NOT NULL
);

CREATE TABLE Friendship (
    Date_create DATE NOT NULL,
    Id_user1 BIGINT NOT NULL,
    Id_user2 BIGINT NOT NULL,
    Id_type INTEGER NOT NULL, 
    FOREIGN KEY (Id_user1) REFERENCES Users (Phone_number),
    FOREIGN KEY (Id_user2) REFERENCES Users (Phone_number),
    FOREIGN KEY (Id_type) REFERENCES RelationshipType (Id_type),
    PRIMARY KEY (Id_user1, Id_user2)
);

CREATE TABLE Study (
    Id_institution SERIAL PRIMARY KEY,
    Name TEXT NOT NULL
);

CREATE TABLE Work (
    Id_work SERIAL PRIMARY KEY,
    Name TEXT NOT NULL
);

CREATE TABLE UsersStudy (
    Id_user BIGINT NOT NULL,
    Id_institution INTEGER NOT NULL,
    Date_admission DATE NOT NULL, 
    Date_graduation DATE NOT NULL,
    FOREIGN KEY (Id_user) REFERENCES Users (Phone_number),
    FOREIGN KEY (Id_institution) REFERENCES Study (Id_institution),
    PRIMARY KEY (Id_user, Id_institution)
);

CREATE TABLE UsersWork (
    Id_user BIGINT NOT NULL,
    Id_work INTEGER NOT NULL,
    Date_start DATE NOT NULL, 
    Date_end DATE NOT NULL,
    FOREIGN KEY (Id_user) REFERENCES Users (Phone_number),
    FOREIGN KEY (Id_work) REFERENCES Work (Id_work),
    PRIMARY KEY (Id_user, Id_work)
);

CREATE TABLE UsersActivity (
    Id_activity SERIAL PRIMARY KEY,
    Phone_number BIGINT NOT NULL,
    Datetime_entry TIMESTAMP NOT NULL, 
    Datetime_exit TIMESTAMP NOT NULL,
    FOREIGN KEY (Phone_number) REFERENCES Users (Phone_number)
);

CREATE TABLE RelationshipType (
    Id_type SERIAL PRIMARY KEY,
    Relationship_type TEXT NOT NULL
);

