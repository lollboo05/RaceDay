USE master;
GO

IF DB_ID('RaceDay') IS NOT NULL
BEGIN
    ALTER DATABASE RaceDay
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    DROP DATABASE RaceDay;
END;
GO

CREATE DATABASE RaceDay;
GO

USE RaceDay;
GO

CREATE TABLE Users
(
    UserID INT IDENTITY(1,1) NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    Role VARCHAR(20) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_Users PRIMARY KEY (UserID),
    CONSTRAINT UQ_Users_Email UNIQUE (Email),
    CONSTRAINT CK_Users_Role
        CHECK (Role IN ('Organiser', 'Participant'))
);
GO

CREATE TABLE Organisers
(
    OrganiserID INT NOT NULL,
    OrganisationName VARCHAR(100) NOT NULL,
    CONSTRAINT PK_Organisers PRIMARY KEY (OrganiserID),
    CONSTRAINT FK_Organisers_Users
        FOREIGN KEY (OrganiserID)
        REFERENCES Users(UserID)
);
GO

CREATE TABLE Participants
(
    ParticipantID INT NOT NULL,
    DateOfBirth DATE NOT NULL,
    EmergencyContactName VARCHAR(100) NOT NULL,
    EmergencyContactPhone VARCHAR(20) NOT NULL,
    CONSTRAINT PK_Participants PRIMARY KEY (ParticipantID),
    CONSTRAINT FK_Participants_Users
        FOREIGN KEY (ParticipantID)
        REFERENCES Users(UserID)
);
GO

CREATE TABLE Events
(
    EventID INT IDENTITY(1,1) NOT NULL,
    OrganiserID INT NOT NULL,
    EventName VARCHAR(150) NOT NULL,
    EventDate DATE NOT NULL,
    Location VARCHAR(150) NOT NULL,
    EventType VARCHAR(30) NOT NULL,
    Description VARCHAR(500) NULL,
    CONSTRAINT PK_Events PRIMARY KEY (EventID),
    CONSTRAINT FK_Events_Organisers
        FOREIGN KEY (OrganiserID)
        REFERENCES Organisers(OrganiserID),
    CONSTRAINT CK_Events_EventType
        CHECK (EventType IN ('Running', 'Walking', 'Cycling'))
);
GO

CREATE TABLE Categories
(
    CategoryID INT IDENTITY(1,1) NOT NULL,
    EventID INT NOT NULL,
    CategoryName VARCHAR(100) NOT NULL,
    DistanceKM DECIMAL(6,2) NOT NULL,
    EntryFee DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_Categories PRIMARY KEY (CategoryID),
    CONSTRAINT FK_Categories_Events
        FOREIGN KEY (EventID)
        REFERENCES Events(EventID),
    CONSTRAINT CK_Categories_Distance
        CHECK (DistanceKM > 0),
    CONSTRAINT CK_Categories_EntryFee
        CHECK (EntryFee >= 0),
    CONSTRAINT UQ_Categories_Event_Category
        UNIQUE (EventID, CategoryName)
);
GO

CREATE TABLE Enrolments
(
    EnrolmentID INT IDENTITY(1,1) NOT NULL,
    ParticipantID INT NOT NULL,
    CategoryID INT NOT NULL,
    EnrolmentDate DATE NOT NULL DEFAULT CONVERT(DATE, GETDATE()),
    EnrolmentStatus VARCHAR(20) NOT NULL DEFAULT 'Confirmed',
    CONSTRAINT PK_Enrolments PRIMARY KEY (EnrolmentID),
    CONSTRAINT FK_Enrolments_Participants
        FOREIGN KEY (ParticipantID)
        REFERENCES Participants(ParticipantID),
    CONSTRAINT FK_Enrolments_Categories
        FOREIGN KEY (CategoryID)
        REFERENCES Categories(CategoryID),
    CONSTRAINT CK_Enrolments_Status
        CHECK (EnrolmentStatus IN ('Pending', 'Confirmed', 'Cancelled')),
    CONSTRAINT UQ_Enrolments_Participant_Category
        UNIQUE (ParticipantID, CategoryID)
);
GO

CREATE TABLE Results
(
    ResultID INT IDENTITY(1,1) NOT NULL,
    EnrolmentID INT NOT NULL,
    FinishTime TIME NULL,
    FinishPosition INT NULL,
    ResultStatus VARCHAR(20) NOT NULL DEFAULT 'Finished',
    CONSTRAINT PK_Results PRIMARY KEY (ResultID),
    CONSTRAINT FK_Results_Enrolments
        FOREIGN KEY (EnrolmentID)
        REFERENCES Enrolments(EnrolmentID),
    CONSTRAINT UQ_Results_Enrolment UNIQUE (EnrolmentID),
    CONSTRAINT CK_Results_Position
        CHECK (FinishPosition IS NULL OR FinishPosition > 0),
    CONSTRAINT CK_Results_Status
        CHECK (ResultStatus IN ('Finished', 'DNF', 'DNS'))
);
GO

CREATE TABLE Routes
(
    RouteID INT IDENTITY(1,1) NOT NULL,
    EventID INT NOT NULL,
    RouteName VARCHAR(150) NOT NULL,
    StartLocation VARCHAR(150) NOT NULL,
    FinishLocation VARCHAR(150) NOT NULL,
    RouteDistanceKM DECIMAL(6,2) NOT NULL,
    CONSTRAINT PK_Routes PRIMARY KEY (RouteID),
    CONSTRAINT FK_Routes_Events
        FOREIGN KEY (EventID)
        REFERENCES Events(EventID),
    CONSTRAINT UQ_Routes_Event UNIQUE (EventID),
    CONSTRAINT CK_Routes_Distance
        CHECK (RouteDistanceKM > 0)
);
GO

INSERT INTO Users
(FirstName, LastName, Email, PasswordHash, Role)
VALUES
('Thabo', 'Mokoena', 'thabo@raceday.co.za', 'HASH001', 'Organiser'),
('Nomsa', 'Dlamini', 'nomsa@raceday.co.za', 'HASH002', 'Organiser'),
('Lerato', 'Nkosi', 'lerato@email.com', 'HASH003', 'Participant'),
('Sipho', 'Mthembu', 'sipho@email.com', 'HASH004', 'Participant');
GO

INSERT INTO Organisers
(OrganiserID, OrganisationName)
VALUES
(1, 'Johannesburg Road Events'),
(2, 'Gauteng Cycling Events');
GO

INSERT INTO Participants
(ParticipantID, DateOfBirth, EmergencyContactName, EmergencyContactPhone)
VALUES
(3, '2002-05-14', 'Mary Nkosi', '0825551001'),
(4, '2001-09-22', 'John Mthembu', '0835551002');
GO

INSERT INTO Events
(OrganiserID, EventName, EventDate, Location, EventType, Description)
VALUES
(1, 'Soweto Road Run', '2026-10-10', 'Soweto, Johannesburg', 'Running', 'Annual road running event in Soweto.'),
(1, 'Johannesburg Community Walk', '2026-10-24', 'Johannesburg', 'Walking', 'Community walking event in Johannesburg.'),
(2, 'Gauteng Cycle Challenge', '2026-11-07', 'Pretoria, Gauteng', 'Cycling', 'Road cycling event through Gauteng.');
GO

INSERT INTO Categories
(EventID, CategoryName, DistanceKM, EntryFee)
VALUES
(1, '10 KM Run', 10.00, 150.00),
(1, '21 KM Half Marathon', 21.10, 250.00),
(2, '5 KM Community Walk', 5.00, 80.00),
(2, '10 KM Walk', 10.00, 120.00),
(3, '40 KM Cycle', 40.00, 200.00),
(3, '80 KM Cycle', 80.00, 350.00);
GO

INSERT INTO Routes
(EventID, RouteName, StartLocation, FinishLocation, RouteDistanceKM)
VALUES
(1, 'Soweto Main Route', 'Soweto Stadium', 'Soweto Stadium', 21.10),
(2, 'Johannesburg Community Route', 'Zoo Lake', 'Zoo Lake', 10.00),
(3, 'Gauteng Cycle Route', 'Pretoria City Centre', 'Pretoria City Centre', 80.00);
GO

INSERT INTO Enrolments
(ParticipantID, CategoryID, EnrolmentDate, EnrolmentStatus)
VALUES
(3, 1, '2026-09-01', 'Confirmed'),
(3, 3, '2026-09-02', 'Confirmed'),
(4, 2, '2026-09-02', 'Confirmed'),
(4, 5, '2026-09-03', 'Confirmed');
GO

INSERT INTO Results
(EnrolmentID, FinishTime, FinishPosition, ResultStatus)
VALUES
(1, '01:05:30', 25, 'Finished'),
(2, '00:38:45', 12, 'Finished');
GO

SELECT * FROM Users;
SELECT * FROM Organisers;
SELECT * FROM Participants;
SELECT * FROM Events;
SELECT * FROM Categories;
SELECT * FROM Enrolments;
SELECT * FROM Results;
SELECT * FROM Routes;
GO