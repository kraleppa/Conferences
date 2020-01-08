--Views

CREATE VIEW view_CityInDictionary as
select c.CityID, c.City, c.CountryID, co.Country
from City as c inner join Country as co on c.CountryID = c.countryID
go


CREATE VIEW view_countriesInDictionary as 
select c.Country from Country as c
go


CREATE VIEW view_cancelledConferences as
select * 
from Conferences
where Cancelled = 1
go


--liczba wolnych/zarezerwowanych miejsc na nadchodzace konferencje
CREATE VIEW view_conferencesSeatsLeft as
select c.ConferenceID, c.ConferenceName, c.Limit, cd.ConferenceDate, 
	c.Limit -
	((select isnull(sum(dr.NormalTickets), 0)
		from DayReservation as dr 
		where dr.ConferenceDayID = cd.ConferenceDayID)
	+
	(select isnull(sum(dr.StudentTickets), 0)
		from DayReservation as dr 
		where dr.ConferenceDayID = cd.ConferenceDayID)) as 'seats left'
from Conferences as c 
	inner join ConferenceDay as cd on cd.ConferenceID = c.ConferenceID
where year(c.StartDate) > year(getdate()) and month(c.StartDate) > month(getdate()) and
	day(c.StartDate) > day(getdate())


