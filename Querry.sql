exec procedure_addConference 'Edukacja2', 'opis', '2022-07-20',
    '2022-07-25',  'Krakow', 'Polska', 'Dluga',
    '20', 0.1, 300, 50

exec procedure_addCompany 'Awiteks', '203677888', '502758927',
    'awiteks@gmail.com', 'Polska', 'Warszawa', 'Wiejska',
    '1'



exec procedure_addWorkshopToDictionary 'Java', 'opis', 20

exec procedure_addWorkshop 1, '2022-07-20', 1, '09:00:00',
    '10:00:00', 20

exec procedure_addIndividualClient 'Barto', 'Szar', '666696888',
    'BartoSz@gmial.com', '502765', 'Polska',
    'Targowica', 'Bartoszowa', '60'

declare @DayListI IndividualReservation;
insert into @DayListI (ConferenceDate)VALUES ('2022-7-20')

exec procedure_addIndividualReservation 1, 1, @DayListI

select * from Reservation

declare @DayList CompanyReservation
insert into @DayList(ConferenceDate, NormalTickets)VALUES('2022-07-20',  10)
declare @StudentList StudentIDCards

exec procedure_addCompanyReservation 2, 1, @DayList, @StudentList

exec procedure_addWorkshopCompanyReservation 2, 3, 2

delete from Reservation where ReservationID = 10

select  * from dbo.function_reservationSummary(3)
select * from Conferences

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

exec procedure_addCompanyEmployeeInformation 1, 5,
    @NameList, @ConferenceList, @WorkshopList

select * from Employee inner join Person P on Employee.PersonID = P.PersonID inner join Student S on P.PersonID = S.PersonID

delete from Reservation where ReservationID = 1

select * from Employee


select * from function_participantListForConference (1)

select * from Workshop


exec procedure_addWorkshop 1, '2022-07-20', 1,
    '08:00:00', '11:00:00', 1

exec procedure_addWorkshopIndividualReservation 1, 2
exec procedure_addWorkshopIndividualReservation 2, 1

delete from Reservation where ReservationID = 1


select * from function_reservationSummary (12)