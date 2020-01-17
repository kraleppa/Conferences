exec procedure_addConference 'Edukacja2', 'opis', '2022-07-20',
    '2022-07-25',  'Krakow', 'Polska', 'Dluga',
    '20', 0.1, 300, 50

exec procedure_addCompany 'Awiteks', '203677888', '502758927',
    'awiteks@gmail.com', 'Polska', 'Warszawa', 'Wiejska',
    '1'



exec procedure_addWorkshopToDictionary 'Java', 'opis', 20

exec procedure_addWorkshop 1, '2021-07-20', 1, '09:00:00',
    '10:00:00', 20


exec  procedure_addWorkshopCompanyReservation 1, 1, 2

select * from WorkshopReservation

declare @DayList CompanyReservation
insert into @DayList(ConferenceDate, NormalTickets)VALUES('2022-07-20',  2)
insert into @DayList(ConferenceDate, NormalTickets)VALUES('2022-07-21',  2)

declare @StudentList StudentIDCards
insert into @StudentList(ConferenceDate, StudentIDCard)VALUES('2021-07-20','305376')
insert into @StudentList(ConferenceDate, StudentIDCard)VALUES('2021-07-21','305376')


exec procedure_addCompanyReservation 1, 2, @DayList, @StudentList

exec

select * from Student

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
VALUES(1, '2022-07-20')
insert into @ConferenceList (IDOsoby, Data)
VALUES(1, '2022-07-21')
insert into @ConferenceList (IDOsoby, Data)
VALUES(2, '2022-07-20')
insert into @ConferenceList (IDOsoby, Data)
VALUES(2, '2022-07-21')
insert into @ConferenceList (IDOsoby, Data)
VALUES(3, '2022-07-20')

insert into @ConferenceList (IDOsoby, Data)
VALUES(3, '2022-07-21')

exec procedure_addCompanyEmployeeInformation 1, 2,
    @NameList, @ConferenceList, @WorkshopList

select * from DayReservation inner join DayParticipant DP on DayReservation.DayReservationID = DP.DayReservationID
order by 1

select * from Employee

exec procedure_addWorkshop 1, '2021-07-20', 1, '09:00:00', '10:00:00', 5000