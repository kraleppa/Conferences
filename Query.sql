select * from function_showUnpaidReservations(1)

select * from Student

select *
from IndividualClient as target
    inner join Employee as e
        on target.PersonID = e.PersonID