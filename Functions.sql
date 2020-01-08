--Functions

CREATE FUNCTION function_partiticipantsOfDayConference(@ConferenceDayID int)
returns table 
as
return(
	select p.FirstName, p.LastName, '' as 'Company'
	from Person as p
		inner join IndividualClient as ic
			on ic.PersonID = p.PersonID
		inner join DayParticipant as dp
			on dp.PersonID = p.PersonID
		inner join DayReservation as dr
			on dr.DayReservationID = dp.DayReservationID
		inner join ConferenceDay as cd
			on cd.ConferenceDayID = dr.ConferenceDayID 
		inner join Conferences as c
			on c.ConferenceID = cd.ConferenceID
	where cd.ConferenceDayID = @ConferenceDayID

	union
	
	select p.FirstName, p.LastName, co.CompanyName as 'Company'
	from Person as p
		inner join Employee as e
			on e.PersonID = p.PersonID
		inner join Company as co 
			on co.ClientID = e.ClientID
		inner join DayParticipant as dp
			on dp.PersonID = p.PersonID
		inner join DayReservation as dr
			on dr.DayReservationID = dp.DayReservationID
		inner join ConferenceDay as cd
			on cd.ConferenceDayID = dr.ConferenceDayID 
		inner join Conferences as c
			on c.ConferenceID = cd.ConferenceID
	where cd.ConferenceDayID = @ConferenceDayID

)
