--usuwanie klientow indywidualnych powielajacyh PersonID pracownikow
delete target
from IndividualClient as target
    inner join Employee as e
        on target.PersonID = e.PersonID

delete p
from Person as p
where p.PersonID not in (select personid from IndividualClient) and
      p.PersonID not in (select PersonID from Employee) and
      p.PersonID not in (select PersonID from Student)