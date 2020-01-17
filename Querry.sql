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






exec procedure_addCompanyReservation 1, 1, @DayList, @StudentList

select * from Reservation inner join DayReservation DR on Reservation.ReservationID = DR.ReservationID

select * from Student