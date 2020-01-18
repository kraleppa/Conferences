--usuwanie klientow idywidualnych powielajacyh ClientID firm
delete target
from IndividualClient as target
    inner join Company C
        on target.ClientID = C.ClientID
