select * from Clients
select * from Conferences

exec procedure_addConference 'Edukacja', 'opis', '2021-07-20', '2021-07-25', 'Krakow',
    'Polska', 'Dluga', '2', 0.1, '300', 200

select * from Conferences

exec procedure_addWorkshopToDictionary 'Java', 'opis', '20'

exec procedure_addWorkshop 1, '2021-07-20', 1, '08:00:00', '09:00:00', 40

exec procedure_addWorkshop 1, '2021-07-21', 1, '08:00:00', '09:00:00', 40

select * from Workshop inner join WorkshopDictionary WD on Workshop.WorkshopDictionaryID = WD.WorkshopDictionaryID

exec procedure_addIndividualClient 'Krzysztof', 'Nalepa', '503748827', 'knalepa@gmail.com', '123456',
    'Polska', 'Krakow', 'Wielopole', '10'

select * from Clients inner join IndividualClient IC on Clients.ClientID = IC.ClientID

declare @DayList1 IndividualReservation
insert into @DayList1(ConferenceDate)VALUES('2021-07-20')
insert into @DayList1(ConferenceDate)VALUES('2021-07-21')
exec procedure_addIndividualReservation 1, 1, @DayList1

select * from Reservation inner join DayReservation DR on Reservation.ReservationID = DR.ReservationID

exec procedure_addWorkshopIndividualReservation 1, 1

select * from WorkshopReservation inner join WorkshopParticipant WP on WorkshopReservation.WorkshopReservationID = WP.WorkshopReservationID
    inner join DayParticipant DP on WP.DayParticipantID = DP.DayParticipantID


exec procedure_addCompany 'AGHA', '666777929', '888782976', 'agh2@agh.edu', 'Polska', 'Krakow',
    'Ulica', '1'

select * from Company inner join Clients C on Company.ClientID = C.ClientID

----------------
declare @DayList2 CompanyReservation
insert into @DayList2(ConferenceDate, NormalTickets)VALUES('2021-07-21', 1)
insert into @DayList2(ConferenceDate, NormalTickets)VALUES('2021-07-22', 1)

declare @StudentList StudentIDCards
insert into @StudentList (ConferenceDate, StudentIDCard)VALUES ('2021-07-21', '203302')
insert into @StudentList (ConferenceDate, StudentIDCard)VALUES ('2021-07-22', '203302')
insert into @StudentList (ConferenceDate, StudentIDCard)VALUES ('2021-07-21', '103302')
insert into @StudentList (ConferenceDate, StudentIDCard)VALUES ('2021-07-22', '203302')


exec procedure_addCompanyReservation 3,  1, @DayList2, @StudentList

select * from Reservation inner join DayReservation DR on Reservation.ReservationID = DR.ReservationID

select * from Person inner join Employee E on Person.PersonID = E.PersonID left outer join Student S on Person.PersonID = S.PersonID

declare @PersonIDList WorkshopReservation
insert into @PersonIDList (PersonID)VALUES (10)
exec procedure_addWorkshopCompanyReservation 3, 2, @PersonIDList


select * from Reservation
exec procedure_removeReservation 3

exec procedure_addWorkshop 1, '2021-07-22', 1, '10:00:00', '11:00:00', 1000
exec procedure_addWorkshop 1, '2021-07-22', 1, '9:00:00', '11:00:00', 1000
select * from Workshop

declare @DayList CompanyReservation
insert into @DayList(ConferenceDate, NormalTickets)VALUES('2021-07-22', 1)

declare @StudentList StudentIDCards
insert into @StudentList (ConferenceDate, StudentIDCard)VALUES ('2021-07-22', '103302')
insert into @StudentList (ConferenceDate, StudentIDCard)VALUES ('2021-07-22', '203302')
exec procedure_addCompanyReservation 4, 1, @DayList, @StudentList

select * from Reservation

select * from Workshop

exec procedure_addWorkshop 1, '2021-07-22', 1, '09:00:00', '10:00:00', 800

select * from Workshop

select * from Company

