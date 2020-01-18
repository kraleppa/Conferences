select * from function_reservationSummary(5)

select * from IndividualClient as ic inner join person as p on ic.PersonID = p.PersonID
order by 2

select * from Employee as ic inner join person as p on ic.PersonID = p.PersonID
order by 2

select * from Clients as c
    inner join  IndividualClient on c.ClientID = IndividualClient.ClientID
inner join Company as c2 on c.ClientID = c2.ClientID
order by 1





select * from ConferenceDay