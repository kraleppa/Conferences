select * from function_showUnpaidReservations(1)

select * from Prices where ConferenceID = 2
select * from Conferences where ConferenceID = 8

select *
from Person
where PersonID not in (select personid from IndividualClient) and
      PersonID not in (select PersonID from Employee) and
      PersonID in (select PersonID from Student)


select * from Prices