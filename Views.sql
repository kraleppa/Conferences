--Views

CREATE VIEW view_CityInDictionary as
	select c.City, co.Country
	from City as c 
		inner join Country as co 
			on c.CountryID = c.countryID
go


CREATE VIEW view_countriesInDictionary as 
	select c.Country 
	from Country as c
go


CREATE VIEW view_cancelledWorkshop as
	select wd.WorkshopName, w.StartTime, w.EndTime, 
		cd.ConferenceDate 
	from Workshop as w
		inner join WorkshopDictionary as wd
			on wd.WorkshopDictionaryID = w.WorkshopDictionaryID
		inner join ConferenceDay as cd
			on cd.ConferenceDayID = w.ConferenceDayID
	where w.cancelled = 1
go


--limit i wolne miejsca na nadchodzace konferencje (na kazdy dzien)
CREATE VIEW view_conferencesSeatsLeft as
	select c.ConferenceID, c.ConferenceName, c.Limit, cd.ConferenceDate, 
		c.Limit -
		isnull(((select sum(dr.NormalTickets)
			from DayReservation as dr 
			where dr.ConferenceDayID = cd.ConferenceDayID)
		+
		(select sum(dr.StudentTickets)
			from DayReservation as dr 
			where dr.ConferenceDayID = cd.ConferenceDayID)), 0) as 'Wolne miejsca'
	from Conferences as c 
		inner join ConferenceDay as cd 
			on cd.ConferenceID = c.ConferenceID
	where c.StartDate > getdate()
go


--wyswietla liczbe wolnych miejsc na nadchodzace warsztaty
--i calkowity limit miejsc
CREATE VIEW view_workshopsSeatLeft as
	select w.WorkshopID, wd.WorkshopName,
		cd.ConferenceDate, w.StartTime, w.EndTime, 
		w.Limit - SUM(wr.Tickets) AS 'Wolne miejsca', 
		w.Limit
	from WorkshopDictionary as wd
		inner join Workshop as w
			on w.WorkshopDictionaryID = wd.WorkshopDictionaryID
		inner join ConferenceDay as cd on 
			w.ConferenceDayID = cd.ConferenceDayID
		inner join WorkshopReservation as wr
			on w.WorkshopID = wr.WorkshopID
	where cd.ConferenceDate > GETDATE() and w.Cancelled <> 1
	group by w.WorkshopID, wd.WorkshopName,
		cd.ConferenceDate, w.StartTime, w.EndTime, w.Limit
go


CREATE VIEW view_workshopDictionary as
	select wd.WorkshopName, wd.WorkshopDescription, wd.Price
		from WorkshopDictionary as wd
go

--fix here
/*
--informacje o nadchodzacyh konferencjach
CREATE VIEW view_conferencesInfo as
	select c.ConferenceName, c.ConferenceDescription, c.limit, c.StartDate, c.EndDate, 
		c.BuildingNumber,c.street, ci.City, co.Country, 
		c.BasePrice*(1-isnull(p.Discount, 0)) as 'Normal ticket price', 
		c.BasePrice*(1-isnull(p.Discount, 0))*(1-c.StudentDiscount) as 'Student ticket price'
	from Conferences as c
		inner join City as ci on ci.CityID = c.CityID
		inner join Country as co on co.CountryID = ci.CountryID
		left outer join prices as p on p.ConferenceID = c.ConferenceID and 
			GETDATE() between p.StartDate and p.EndDate 
	where c.StartDate >= getdate()
go
*/

--wyswietla rezerwacje ktore powinny zostac usuniete
CREATE VIEW view_reservationOnConferenceToDelete as 
	select r.ReservationID, r.ClientID, dr.NormalTickets, dr.StudentTickets,
		DATEADD(day, 7, r.ReservationDate) as 'Payment deadline',
		c.ConferenceID, c.ConferenceName  
		from Reservation as r
		inner join DayReservation as dr 
			on dr.ReservationID = r.ReservationID
		inner join ConferenceDay as cd 
			on cd.ConferenceDayID = dr.ConferenceDayID
		inner join Conferences as c
			on c.ConferenceID = cd.ConferenceID
	where PaymentDate is null and 
		DATEDIFF(day, DATEADD(day, 7, r.ReservationDate), GETDATE()) > 0
go


--firmy, ktore nie uzupelnily wszystkich uczestnikow 2 tygodnie przed konferencja
CREATE VIEW view_companiesYetToFillEmployees as
	select com.ClientID, com.CompanyName, com.NIP, cl.Email, cl.Phone
	from Company as com
		inner join Clients as cl on cl.ClientID = com.ClientID
		inner join Reservation as r on r.ClientID = cl.ClientID
		inner join DayReservation as dr on dr.ReservationID = r.ReservationID
		inner join ConferenceDay as cd on cd.ConferenceDayID = dr.ConferenceDayID
		inner join Conferences as c on c.ConferenceID = cd.ConferenceID
	where datediff(day, getdate(), c.StartDate) <= 14 and exists 
		(select *
			from Employee as e
				inner join Person as p
					on e.PersonID = p.PersonID
				inner join DayParticipant as dp2
					on dp2.PersonID = p.PersonID and
					dp2.DayReservationID = dr.DayReservationID
			where e.Firstname is null or e.Lastname is null
		)
go


--wyswietla nadchodzace warsztaty
CREATE VIEW view_upcomingWorkshops as
	select w.WorkshopID, wd.WorkshopName, wd.WorkshopDescription, wd.Price,
		c.ConferenceID, c.ConferenceName, cd.ConferenceDate, w.StartTime, w.EndTime
		from Workshop as w 
		inner join WorkshopDictionary as wd
			on wd.WorkshopDictionaryID = w.WorkshopDictionaryID
		inner join ConferenceDay as cd
			on cd.ConferenceDayID = w.ConferenceDayID
		inner join Conferences as c
			on c.ConferenceID = cd.ConferenceID
	where (cd.ConferenceDate > GETDATE() and w.Cancelled <> 1)
go

