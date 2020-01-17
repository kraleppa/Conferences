exec procedure_addConference 'Edukacja', 'opis', '2021-07-20',
    '2021-07-25',  'Krakow', 'Polska', 'Dluga',
    '20', 0.1, 300, 50

exec procedure_addCompany 'Awiteks', '203677888', '502758927',
    'awiteks@gmail.com', 'Polska', 'Warszawa', 'Wiejska',
    '1'

declare @DayList CompanyReservation
insert into @DayList(ConferenceDate, NormalTickets)VALUES('2021-07-20',  2)
insert into @DayList(ConferenceDate, NormalTickets)VALUES('2021-07-21',  2)

declare @StudentList StudentIDCards
insert into @StudentList(ConferenceDate, StudentIDCard)VALUES('2021-07-20','305376')
insert into @StudentList(ConferenceDate, StudentIDCard)VALUES('2021-07-21','305376')

exec procedure_addWorkshopToDictionary 'Java', 'opis', 20

exec procedure_addWorkshop 1, '2021-07-20', 1, '09:00:00',
    '10:00:00', 20


exec  procedure_addWorkshopCompanyReservation 1, 1, 2

select * from WorkshopReservation




exec procedure_addCompanyReservation 1, 1, @DayList, @StudentList


select  * from dbo.function_reservationSummary(1)

declare @NameList NamesTable
declare @ConferenceList ConferenceTable
declare @WorkshopList WorkshopTable

insert into @NameList(Imie, Nazwisko, Legitymacja)
VALUES ('Krzysztof', 'Nalepa', '305376')
insert into @NameList(Imie, Nazwisko, Legitymacja)
VALUES ('Jan', 'Kowalski', null)
insert into @NameList(Imie, Nazwisko, Legitymacja)
VALUES ('Marcin', 'Nowak', null)

insert into @ConferenceList (IDOsoby, Data)
VALUES(1, '2021-07-20')
insert into @ConferenceList (IDOsoby, Data)
VALUES(1, '2021-07-21')
insert into @ConferenceList (IDOsoby, Data)
VALUES(2, '2021-07-20')
insert into @ConferenceList (IDOsoby, Data)
VALUES(2, '2021-07-21')
insert into @ConferenceList (IDOsoby, Data)
VALUES(3, '2021-07-20')
insert into @ConferenceList (IDOsoby, Data)
VALUES(3, '2021-07-21')

insert into @WorkshopList (IDOsoby, WorkshopID)
VALUES (1, 1)
insert into @WorkshopList (IDOsoby, WorkshopID)
VALUES (2, 1)

exec procedure_addCompanyEmployeeInformation 1, 1,
    @NameList, @ConferenceList, @WorkshopList

select * from Employee inner join Person P on Employee.PersonID = P.PersonID inner join DayParticipant DP on P.PersonID = DP.PersonID inner join WorkshopParticipant WP on DP.DayParticipantID = WP.DayParticipantID