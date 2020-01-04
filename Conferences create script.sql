use u_nalepa
-- tables
-- Table: City
CREATE TABLE City (
    CityID int identity(1,1) NOT NULL
		CONSTRAINT City_pk PRIMARY KEY,
    CountryID int  NOT NULL,
    City varchar(50)  NOT NULL,
);

-- Table: Clients
CREATE TABLE Clients (
    ClientID int identity(1,1)NOT NULL
		CONSTRAINT Clients_pk PRIMARY KEY,
    Phone varchar(9) NOT NULL
		check (isnumeric([phone]) = 1),
    Street varchar(50)  NOT NULL,
    PostalCode varchar(10)  NOT NULL,
		check (([PostalCode] like '[0-9][0-9]-[0-9][0-9][0-9]'
			or [PostalCode] like '[0-9][0-9][0-9][0-9][0-9]'
			or [PostalCode] like '[0-9][0-9][0-9][0-9][0-9][0-9]')),
    CityID int  NOT NULL,
);

-- Table: Company
CREATE TABLE Company (
    ClientID int  NOT NULL
		constraint Copmany_pk primary key,
    CompanyName varchar(50)  NOT NULL,
    NIP varchar(10)  NOT NULL
		check (isnumeric([NIP]) = 1),
    Email varchar(40)  NOT NULL
		check ([Email] like '*@*.*') 
);

-- Table: ConferenceDay
CREATE TABLE ConferenceDay (
    ConferenceDayID int  NOT NULL,
    ConferenceID int  NOT NULL,
    ConferenceDate date  NOT NULL,
    CONSTRAINT ConferenceDay_pk PRIMARY KEY  (ConferenceDayID)
);

-- Table: Conferences
CREATE TABLE Conferences (
    ConferenceID int identity(1,1)  NOT NULL
		CONSTRAINT Conferences_pk PRIMARY KEY,
    ConferenceName varchar(50)  NOT NULL,
    ConferenceDescription varchar(255)  NOT NULL,
    StartDate date  NOT NULL,
    EndDate date  NOT NULL
		check([EndDate] > [StartDate]),
    CityID int  NOT NULL,
    Street varchar(50)  NOT NULL,
    BuildingNumber int  NOT NULL
		check([BuildingNumber] > 0),
    StudentDiscount real  NOT NULL
		check([StudentDiscount] >= 0),
    Limit int  NOT NULL
		check([Limit] > 0),
    Cancelled bit NULL default 0,
    BasePrice money  NOT NULL
		check([BasePrice] > 0),
);

-- Table: Country
CREATE TABLE Country (
    CountryID int identity(1,1) NOT NULL
		CONSTRAINT Country_pk PRIMARY KEY,
    Country varchar(50)  NOT NULL,
);

-- Table: DayParticipant
CREATE TABLE DayParticipant (
    DayParticipantID int identity(1,1)  NOT NULL
		CONSTRAINT DayParticipant_pk PRIMARY KEY,
    PersonID int  NOT NULL,
    DayReservationID int  NOT NULL,
);

-- Table: DayReservation
CREATE TABLE DayReservation (
    DayReservationID int  NOT NULL,
    ConferenceDayID int  NOT NULL,
    ResevationID int  NOT NULL,
    NormalTickets int  NOT NULL,
    StudentTickets int  NULL,
    CONSTRAINT DayReservation_pk PRIMARY KEY  (DayReservationID)
);

-- Table: Employee
CREATE TABLE Employee (
    ClientID int  NOT NULL,
    PersonID int  NOT NULL,
    CONSTRAINT Employee_pk PRIMARY KEY  (PersonID)
);

-- Table: IndividualClient
CREATE TABLE IndividualClient (
    ClientID int  NOT NULL,
    PersonID int  NOT NULL unique,
    CONSTRAINT IndividualClient_pk PRIMARY KEY  (ClientID)
);

-- Table: Person
CREATE TABLE Person (
    PersonID int  NOT NULL,
    FirstName varchar(20)  NOT NULL,
    LastName varchar(40)  NOT NULL,
    Email varchar(30)  NOT NULL,
    CONSTRAINT Person_pk PRIMARY KEY  (PersonID)
);

-- Table: Prices
CREATE TABLE Prices (
    PriceID int  NOT NULL,
    ConferenceID int  NOT NULL,
    StartDate date  NOT NULL,
    EndDate date  NOT NULL,
    Discount real  NOT NULL,
    CONSTRAINT Prices_pk PRIMARY KEY  (PriceID)
);

-- Table: Resvervation
CREATE TABLE Resvervation (
    ResevationID int  NOT NULL,
    ClientID int  NOT NULL,
    PaymentDate date  NULL,
    ReservationDate date  NOT NULL,
    CONSTRAINT Resvervation_pk PRIMARY KEY  (ResevationID)
);

-- Table: Student
CREATE TABLE Student (
    StudentID int  NOT NULL
		CONSTRAINT Student_pk PRIMARY KEY,
    PersonID int  NULL unique,
    StudentCardID varchar(6)  NOT NULL unique,
    ResevationID int  NOT NULL,
);

-- Table: Workshop
CREATE TABLE Workshop (
    WorkshopID int identity(1,1) NOT NULL
		CONSTRAINT Workshop_pk PRIMARY KEY,
    WorkshopDictionaryID int  NOT NULL,
    ConferenceDayID int  NOT NULL,
    StartTime time  NOT NULL,
    EndTime time  NOT NULL
		check([EndTime] > [StartTime]),
    Limit int  NOT NULL 
		check ([Limit] > 0),
    Cancelled bit  NULL default 0,
    Price money  NOT NULL,
);

-- Table: WorkshopDictionary
CREATE TABLE WorkshopDictionary (
    WorkshopDictionaryID int identity (1, 1) NOT NULL
		 CONSTRAINT WorkshopDictionary_pk PRIMARY KEY,
    WorkshopName varchar(50)  NOT NULL,
    WorkshopDescription varchar(255)  NOT NULL,
    Price money  NULL default 0
   
);

-- Table: WorkshopParticipant
CREATE TABLE WorkshopParticipant (
    DayParticipantID int  NOT NULL,
    WorkshopReservationID int  NOT NULL,
    CONSTRAINT WorkshopParticipant_pk PRIMARY KEY  (DayParticipantID,WorkshopReservationID)
);

-- Table: WorkshopReservation
CREATE TABLE WorkshopReservation (
    WorkshopReservationID int  NOT NULL,
    WorkshopID int  NOT NULL,
    DayReservationID int  NOT NULL,
    NormalTickets int  NOT NULL,
    CONSTRAINT WorkshopReservation_pk PRIMARY KEY  (WorkshopReservationID)
);

-- foreign keys
-- Reference: City_Country (table: City)
ALTER TABLE City ADD CONSTRAINT City_Country
    FOREIGN KEY (CountryID)
    REFERENCES Country (CountryID);

-- Reference: Clients_City (table: Clients)
ALTER TABLE Clients ADD CONSTRAINT Clients_City
    FOREIGN KEY (CityID)
    REFERENCES City (CityID);

-- Reference: Company_Clients (table: Company)
ALTER TABLE Company ADD CONSTRAINT Company_Clients
    FOREIGN KEY (ClientID)
    REFERENCES Clients (ClientID);

-- Reference: ConferenceDay_Conferences (table: ConferenceDay)
ALTER TABLE ConferenceDay ADD CONSTRAINT ConferenceDay_Conferences
    FOREIGN KEY (ConferenceID)
    REFERENCES Conferences (ConferenceID);

-- Reference: Conferences_City (table: Conferences)
ALTER TABLE Conferences ADD CONSTRAINT Conferences_City
    FOREIGN KEY (CityID)
    REFERENCES City (CityID);

-- Reference: DayParticipant_DayReservation (table: DayParticipant)
ALTER TABLE DayParticipant ADD CONSTRAINT DayParticipant_DayReservation
    FOREIGN KEY (DayReservationID)
    REFERENCES DayReservation (DayReservationID);

-- Reference: DayParticipant_Person (table: DayParticipant)
ALTER TABLE DayParticipant ADD CONSTRAINT DayParticipant_Person
    FOREIGN KEY (PersonID)
    REFERENCES Person (PersonID);

-- Reference: DayReservation_ConferenceDay (table: DayReservation)
ALTER TABLE DayReservation ADD CONSTRAINT DayReservation_ConferenceDay
    FOREIGN KEY (ConferenceDayID)
    REFERENCES ConferenceDay (ConferenceDayID);

-- Reference: DayReservation_Resvervation (table: DayReservation)
ALTER TABLE DayReservation ADD CONSTRAINT DayReservation_Resvervation
    FOREIGN KEY (ResevationID)
    REFERENCES Resvervation (ResevationID);

-- Reference: Employee_Company (table: Employee)
ALTER TABLE Employee ADD CONSTRAINT Employee_Company
    FOREIGN KEY (ClientID)
    REFERENCES Company (ClientID);

-- Reference: Employee_Person (table: Employee)
ALTER TABLE Employee ADD CONSTRAINT Employee_Person
    FOREIGN KEY (PersonID)
    REFERENCES Person (PersonID);

-- Reference: IndividualClient_Clients (table: IndividualClient)
ALTER TABLE IndividualClient ADD CONSTRAINT IndividualClient_Clients
    FOREIGN KEY (ClientID)
    REFERENCES Clients (ClientID);

-- Reference: IndividualClient_Person (table: IndividualClient)
ALTER TABLE IndividualClient ADD CONSTRAINT IndividualClient_Person
    FOREIGN KEY (PersonID)
    REFERENCES Person (PersonID);

-- Reference: Prices_Conferences (table: Prices)
ALTER TABLE Prices ADD CONSTRAINT Prices_Conferences
    FOREIGN KEY (ConferenceID)
    REFERENCES Conferences (ConferenceID);

-- Reference: Resvervation_Clients (table: Resvervation)
ALTER TABLE Resvervation ADD CONSTRAINT Resvervation_Clients
    FOREIGN KEY (ClientID)
    REFERENCES Clients (ClientID);

-- Reference: Student_Person (table: Student)
ALTER TABLE Student ADD CONSTRAINT Student_Person
    FOREIGN KEY (PersonID)
    REFERENCES Person (PersonID);

-- Reference: Student_Resvervation (table: Student)
ALTER TABLE Student ADD CONSTRAINT Student_Resvervation
    FOREIGN KEY (ResevationID)
    REFERENCES Resvervation (ResevationID);

-- Reference: WorkshopParticipant_DayParticipant (table: WorkshopParticipant)
ALTER TABLE WorkshopParticipant ADD CONSTRAINT WorkshopParticipant_DayParticipant
    FOREIGN KEY (DayParticipantID)
    REFERENCES DayParticipant (DayParticipantID);

-- Reference: WorkshopParticipant_WorkshopReservation (table: WorkshopParticipant)
ALTER TABLE WorkshopParticipant ADD CONSTRAINT WorkshopParticipant_WorkshopReservation
    FOREIGN KEY (WorkshopReservationID)
    REFERENCES WorkshopReservation (WorkshopReservationID);

-- Reference: WorkshopReservation_DayReservation (table: WorkshopReservation)
ALTER TABLE WorkshopReservation ADD CONSTRAINT WorkshopReservation_DayReservation
    FOREIGN KEY (DayReservationID)
    REFERENCES DayReservation (DayReservationID);

-- Reference: WorkshopReservation_Workshop (table: WorkshopReservation)
ALTER TABLE WorkshopReservation ADD CONSTRAINT WorkshopReservation_Workshop
    FOREIGN KEY (WorkshopID)
    REFERENCES Workshop (WorkshopID);

-- Reference: Workshop_ConferenceDay (table: Workshop)
ALTER TABLE Workshop ADD CONSTRAINT Workshop_ConferenceDay
    FOREIGN KEY (ConferenceDayID)
    REFERENCES ConferenceDay (ConferenceDayID);

-- Reference: Workshop_WorkshopDictionary (table: Workshop)
ALTER TABLE Workshop ADD CONSTRAINT Workshop_WorkshopDictionary
    FOREIGN KEY (WorkshopDictionaryID)
    REFERENCES WorkshopDictionary (WorkshopDictionaryID);
	

