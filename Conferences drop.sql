use u_nalepa

-- foreign keys
ALTER TABLE City DROP CONSTRAINT City_Country;

ALTER TABLE Clients DROP CONSTRAINT Clients_City;

ALTER TABLE Company DROP CONSTRAINT Company_Clients;

ALTER TABLE ConferenceDay DROP CONSTRAINT ConferenceDay_Conferences;

ALTER TABLE Conferences DROP CONSTRAINT Conferences_City;

ALTER TABLE DayParticipant DROP CONSTRAINT DayParticipant_DayReservation;

ALTER TABLE DayParticipant DROP CONSTRAINT DayParticipant_Person;

ALTER TABLE DayReservation DROP CONSTRAINT DayReservation_ConferenceDay;

ALTER TABLE DayReservation DROP CONSTRAINT DayReservation_Resvervation;

ALTER TABLE Employee DROP CONSTRAINT Employee_Company;

ALTER TABLE Employee DROP CONSTRAINT Employee_Person;

ALTER TABLE IndividualClient DROP CONSTRAINT IndividualClient_Clients;

ALTER TABLE IndividualClient DROP CONSTRAINT IndividualClient_Person;

ALTER TABLE Prices DROP CONSTRAINT Prices_Conferences;

ALTER TABLE Resvervation DROP CONSTRAINT Resvervation_Clients;

ALTER TABLE Student DROP CONSTRAINT Student_Person;

ALTER TABLE Student DROP CONSTRAINT Student_Resvervation;

ALTER TABLE WorkshopParticipant DROP CONSTRAINT WorkshopParticipant_DayParticipant;

ALTER TABLE WorkshopParticipant DROP CONSTRAINT WorkshopParticipant_WorkshopReservation;

ALTER TABLE WorkshopReservation DROP CONSTRAINT WorkshopReservation_DayReservation;

ALTER TABLE WorkshopReservation DROP CONSTRAINT WorkshopReservation_Workshop;

ALTER TABLE Workshop DROP CONSTRAINT Workshop_ConferenceDay;

ALTER TABLE Workshop DROP CONSTRAINT Workshop_WorkshopDictionary;

-- tables
DROP TABLE City;

DROP TABLE Clients;

DROP TABLE Company;

DROP TABLE ConferenceDay;

DROP TABLE Conferences;

DROP TABLE Country;

DROP TABLE DayParticipant;

DROP TABLE DayReservation;

DROP TABLE Employee;

DROP TABLE IndividualClient;

DROP TABLE Person;

DROP TABLE Prices;

DROP TABLE Resvervation;

DROP TABLE Student;

DROP TABLE Workshop;

DROP TABLE WorkshopDictionary;

DROP TABLE WorkshopParticipant;

DROP TABLE WorkshopReservation;

