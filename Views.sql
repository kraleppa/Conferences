--Views

CREATE VIEW view_CityInDictionary as
select c.CityID, c.City, c.CountryID, co.Country
from City as c inner join Country as co on c.CountryID = c.countryID
go

CREATE VIEW view_countriesInDictionary as 
select c.Country from Country as c
go


CREATE VIEW view_cancelledWorkshop as
select wd.WorkshopName, cd.ConferenceDate from Workshop as w
inner join WorkshopDictionary as wd
on wd.WorkshopDictionaryID = w.WorkshopDictionaryID
inner join ConferenceDay as cd
on cd.ConferenceDayID = w.ConferenceDayID
go

CREATE VIEW view_cancelledConferences as
select * 
from Conferences
where Cancelled = 1
go

--wyswietla liczbe miejsc zarezerwowanych na nadchodzace warsztaty
--i calkowity limit miejsc
CREATE VIEW view_workshopsSeatLimit as 
select w.WorkshopID, wd.WorkshopName, wd.WorkshopDescription,
	cd.ConferenceDate, w.StartTime, w.EndTime, 
	SUM(wr.NormalTickets) AS 'Booked Places', w.Limit AS 'Total Places'
from WorkshopDictionary as wd
	inner join Workshop as w
		on w.WorkshopDictionaryID = wd.WorkshopDictionaryID
	inner join ConferenceDay as cd on 
		w.ConferenceDayID = cd.ConferenceDayID
	left outer join WorkshopReservation as wr
		on w.WorkshopID = wr.WorkshopID
where (cd.ConferenceDate > GETDATE() and w.Cancelled <> 1)
group by w.WorkshopID, wd.WorkshopName, wd.WorkshopDescription,
			cd.ConferenceDate, w.StartTime, w.EndTime, w.Limit
go