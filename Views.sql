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
select w.WorkshopID, wd.WorkshopName,
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
group by w.WorkshopID, wd.WorkshopName,
			cd.ConferenceDate, w.StartTime, w.EndTime, w.Limit
go

CREATE VIEW view_workshopDictionary as
select wd.WorkshopName, wd.WorkshopDescription, wd.Price
	from WorkshopDictionary as wd
go

--wyswietla rezerwacje na konferencje ktore nie zostaly oplacone
CREATE VIEW view_reservtionOnConferenceToDelete as 
select r.ResevationID, r.ClientID, dr.NormalTickets, dr.StudentTickets,
	DATEADD(day, 7, r.ReservationDate) as 'Deadline',
	c.ConferenceID, c.ConferenceName  
	from Reservation as r
	inner join DayReservation as dr 
		on dr.ResevationID = r.ResevationID
	inner join ConferenceDay as cd 
		on cd.ConferenceDayID = dr.ConferenceDayID
	inner join Conferences as c
		on c.ConferenceID = cd.ConferenceID
where PaymentDate is null and DATEDIFF(day, DATEADD(day, 7, r.ReservationDate), GETDATE()) > 0

