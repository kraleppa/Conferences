--usuwanie klientow indywidualnych powielajacyh PersonID pracownikow
delete target
from IndividualClient as target
    inner join Employee as e
        on target.PersonID = e.PersonID