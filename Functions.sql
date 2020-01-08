--Functions

--lista warsztatow dla konferencji
create function function_workshopsDuringConference(@conf_id int)
	returns table
	as
	return (
		select conf.ConferenceName, cd.ConferenceDate, wd.WorkshopName, 
			w.StartTime, w.EndTime
		from Conferences as conf
			inner join ConferenceDay as cd 
				on cd.ConferenceID = conf.ConferenceID
			inner join Workshop as w 
				on w.ConferenceDayID = cd.ConferenceDayID
			inner join WorkshopDictionary as wd 
				on wd.WorkshopDictionaryID = w.WorkshopDictionaryID
		where conf.Cancelled = 0 and w.Cancelled = 0 and conf.ConferenceID = @conf_id
	)
go


--lista uczestnikow konferencji (do identyfikatorow)
create function function_participantListForConference(@conf_id int)
	returns table
	as
	return (
		select p.FirstName, p.LastName, 
			iif(com.CompanyName is not null, com.CompanyName, '') as 'Company Name'
		from person as p
			left outer join Employee as e 
				on e.PersonID = p.PersonID
			left outer join Company as com 
				on com.ClientID = e.ClientID
			inner join DayParticipant as dp 
				on dp.PersonID = p.PersonID
			inner join DayReservation as dr 
				on dr.DayReservationID = dp.DayReservationID
			inner join ConferenceDay as cd 
				on cd.ConferenceDayID = dr.ConferenceDayID
			inner join Conferences as conf 
				on conf.ConferenceID = cd.ConferenceID
		where conf.ConferenceID = @conf_id
	)
go