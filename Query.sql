select * from Clients
select * from Conferences

sele

exec procedure_addCompany '123056789', 'Wiejska', 'Kraków','Polska', '1', 'lawaa@wp.pl', '50201', 'xd'
exec procedure_addCompany '606909872', 'Krótka', 'Warszawa', 'Polska', '22', 'autonalepa@onet.pl', '7845288771', 'Auto Nalepa'
exec procedure_addCompany '510263473', 'Jana Pawła', 'Lublin', 'Polska', '30', 'ciastak@gmail.com', '999086023', 'Ciastka.pl'
exec procedure_addCompany '666897698', 'Jana Pawła', 'Lublin', 'Polska', '29', 'torty@gmail.com', '923286023', 'Torty.pl'
exec procedure_addCompany '6', 'Jana Pawła', 'Lublin', 'Polska', '29', 'rty@ml.com', '9202', 'T.l'
select * from Company
declare @DayList CompanyReservation;
insert into @DayList (ConferenceDate, NormalTickets)VALUES('2021-09-10', 10)
insert into @DayList (ConferenceDate, NormalTickets)VALUES ('2021-09-11', 2)

declare @StudentList StudentIDCards;
insert into @StudentList (ConferenceDate, StudentIDCard)VALUES ('2021-09-01', '132')
insert into @StudentList (ConferenceDate, StudentIDCard)VALUES ('2021-09-11', '33231276')
exec procedure_addCompanyReservation 3, 1, @DayList, @StudentList
select * from Reservation
select * from DayReservation

select * from Employee
select * from Student
select * from DayParticipant
select * from Student

select * from Reservation
select * from DayReservation
select * from Employee



select * from DayParticipant
select * from Reservation
select * from DayReservation
select * from DayParticipant
select * from IndividualClient
