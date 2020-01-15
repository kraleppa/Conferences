--Functions

--zwraca liste uczestnikow danego dnia konferencji
create function function_participantsOfDayConference(@ConferenceDayID int)
	returns table 
	as
	return(
		select ind.firstname, ind.lastname, '' as 'Company'
		from IndividualClient as ind
			inner join Person as p 
				on p.PersonID = ind.PersonID
			inner join DayParticipant as dp 
				on dp.PersonID = p.PersonID
			inner join DayReservation as dr 
				on dr.DayReservationID = dp.DayReservationID
		where dr.ConferenceDayID = @ConferenceDayID
		union
		select e.firstname, e.lastname, c.companyname as 'Company'
		from Employee as e
			inner join Company as c 
				on c.ClientID = e.ClientID
			inner join Person as p 
				on p.PersonID = e.PersonID
			inner join DayParticipant as dp 
				on dp.PersonID = p.PersonID
			inner join DayReservation as dr 
				on dr.DayReservationID = dp.DayReservationID
		where dr.ConferenceDayID = @ConferenceDayID
)
go


--lista warsztatow dla konferencji
create function function_workshopsDuringConference(@conf_id int)
	returns table
	as
	return (
		select conf.ConferenceName, cd.ConferenceDate, wd.WorkshopName, 
		wd.WorkshopDescription, w.limit, w.StartTime, w.EndTime, w.Price
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


--zwraca liste uczestnikow danego warsztatu
create function function_participantsOfWorkshop(@WorkshopID int)
	returns table	
	as
	return(
		select ind.firstname, ind.lastname, '' as 'Company'
		from IndividualClient as ind
			inner join Person as p 
				on p.PersonID = ind.PersonID
			inner join DayParticipant as dp 
				on dp.PersonID = p.PersonID
			inner join WorkshopParticipant as wp
				on wp.DayParticipantID = dp.DayParticipantID
			inner join WorkshopReservation as wr
				on wr.WorkshopReservationID = wp.WorkshopReservationID
		where wr.WorkshopID = @WorkshopID
		union
		select e.firstname, e.lastname, c.companyname as 'Company'
		from Employee as e
			inner join Company as c
				on c.ClientID = e.ClientID
			inner join Person as p 
				on p.PersonID = e.PersonID
			inner join DayParticipant as dp 
				on dp.PersonID = p.PersonID
			inner join WorkshopParticipant as wp
				on wp.DayParticipantID = dp.DayParticipantID
			inner join WorkshopReservation as wr
				on wr.WorkshopReservationID = wp.WorkshopReservationID
		where wr.WorkshopID = @WorkshopID
	)
go


--lista uczestnikow konferencji (do identyfikatorow)
create function function_participantListForConference(@conf_id int)
	returns table
	as
	return (
		select ind.firstname, ind.lastname, '' as 'Company'
		from IndividualClient as ind
			inner join Person as p 
				on p.PersonID = ind.PersonID
			inner join DayParticipant as dp 
				on dp.PersonID = p.PersonID
			inner join DayReservation as dr 
				on dr.DayReservationID = dp.DayReservationID
			inner join ConferenceDay as cd
				on cd.ConferenceDayID = dr.ConferenceDayID
		where cd.ConferenceID = @conf_id
		union 
		select e.firstname, e.lastname, c.CompanyName as 'Company'
		from employee as e
			inner join Company as c
				on c.ClientID = e.ClientID
			inner join Person as p 
				on p.PersonID = e.PersonID
			inner join DayParticipant as dp 
				on dp.PersonID = p.PersonID
			inner join DayReservation as dr 
				on dr.DayReservationID = dp.DayReservationID
			inner join ConferenceDay as cd
				on cd.ConferenceDayID = dr.ConferenceDayID
		where cd.ConferenceID = @conf_id
	)
go


--funkcja zwracajaca top X aktywnych (wg ilosci 
--oplaconych rezerwacji) klientow indywidualnych
create function function_topIndividualClients(@X int)
	returns table
	as
	return (
		select top(@x) c.ClientID, ic.FirstName, ic.LastName, 
			count(r.ReservationID) as 'Liczba op³aconych rezerwacji'
		from Clients as c
			inner join IndividualClient as ic
				on ic.ClientID = c.ClientID
			inner join Person as p
				on p.PersonID = ic.PersonID
			inner join Reservation as r
				on r.ClientID = c.ClientID
		where r.PaymentDate is not null
		group by c.ClientID, ic.FirstName, ic.LastName
		order by 4 desc
	)
go


--top X firm wg zakupionych biletow
create function function_topCompaniesByTickets(@x int)
	returns table 
	as
	return (
		select top(@x) com.CompanyName, 
			sum(dr.NormalTickets) 
			+ 
			sum(dr.StudentTickets) 
			as 'Total number of tickets'
		from Company as com
			inner join Clients as cl 
				on cl.ClientID = com.ClientID
			inner join Reservation as r 
				on r.ClientID = cl.ClientID
				and r.PaymentDate is not null
			inner join DayReservation as dr 
				on dr.ReservationID = r.ReservationID
		group by com.CompanyName
		order by 2 desc
	)
go


--top x firm wg rezerwacji
create function function_topCompaniesByReservations(@x int)
	returns table 
	as
	return (
		select top(@x) com.CompanyName, 
			count(r.ReservationID) as 'Liczba op³aconych rezerwacji'
		from Company as com
			inner join Clients as cl 
				on cl.ClientID = com.ClientID
			inner join Reservation as r 
				on r.ClientID = cl.ClientID
				and r.PaymentDate is not null
		group by com.CompanyName
		order by count(r.ReservationID) desc
	)
go


--zwraca ID dnia konferencji (o podanej dacie)
create function function_returnConferenceDay(@ConferenceID int, @Date date)
    returns int
    as
    begin
		return (
			select ConferenceDayID
			from ConferenceDay
			where ConferenceID = @ConferenceID and ConferenceDate = @Date
		)
		end
go


--zwraca cene warsztatu
create function function_returnValueOfWorkshop(@WorkshopDictionaryID int)
    returns money
    as
    begin
		return (
			select Price from WorkshopDictionary
			where WorkshopDictionaryID = @WorkshopDictionaryID
			)
		end
go 


--zwraca ID osoby
create function function_returnPersonID(@ReservationID int)
	returns int
	as
	begin
		return (
				select p.PersonID 
				from Clients as c
				inner join IndividualClient as id 
					on id.ClientID = c.ClientID
				inner join Person as p 
					on id.PersonID = p.PersonID
				where (select ClientID from Reservation as r
						where ReservationID = @ReservationID) = c.ClientID
			)
	end
go

--zwraca listê rezerwacji które nie zosta³y op³acone oraz czas jaki pozosta³
--na op³acenie rezerwacji
create function function_unpaidReservations(@ClientID int)
	returns table
	as
	return (
		select ReservationID, 
			DATEDIFF(day, GETDATE(), DATEADD(day, 7, ReservationDate)) as 'Days left'
		from Reservation 
		where ClientID = 1
			and PaymentDate is null
	)
go


--zwraca cene normalnego biletu w danej rezerwacji
create function function_returnNormalTicketCost(@reservationID int)
	returns int
	as
	begin
		return (
			select c.BasePrice*(1-isnull(p.Discount, 0))
			from Conferences as c
				left outer join Prices as p
					on p.ConferenceID = c.ConferenceID and 
						(
							select ReservationDate 
							from Reservation 
							where ReservationID = @reservationID
						) between p.StartDate and p.EndDate	
			where c.ConferenceID = (
				select distinct cd.ConferenceID
				from DayReservation as dr
					inner join Reservation as r 
						on r.ReservationID = dr.ReservationID
					inner join	ConferenceDay as cd 
						on cd.ConferenceDayID = dr.ConferenceDayID
				where r.ReservationID = @reservationID
			)
		)
	end
go


--zwraca cene studenckiego biletu dla rezerwacji
create function function_returnStudentTicketCost(@reservationID int)
	returns int
	as
	begin
		return (
			select c.BasePrice*(1-isnull(p.Discount, 0))*(1-c.StudentDiscount)
			from Conferences as c
				left outer join Prices as p
					on p.ConferenceID = c.ConferenceID and 
						(
							select ReservationDate 
							from Reservation 
							where ReservationID = @reservationID
						) between p.StartDate and p.EndDate	
			where c.ConferenceID = (
				select distinct cd.ConferenceID
				from DayReservation as dr
					inner join Reservation as r 
						on r.ReservationID = dr.ReservationID
					inner join	ConferenceDay as cd 
						on cd.ConferenceDayID = dr.ConferenceDayID
				where r.ReservationID = @reservationID
			)
		)
	end
go


--wyswetlanie szczegolow rezerwacji
create function function_reservationInfo(@reservationID int)
	returns table
	as
	return (
		select concat('Konferencja: ', c.ConferenceName, ', Data: ',
			cd.ConferenceDate, ' - ', 'Liczba biletów normalnych: ', dr.NormalTickets)
				as ReservationInfo
		from DayReservation as dr
			inner join ConferenceDay as cd
				on cd.ConferenceDayID = dr.ConferenceDayID
			inner join Conferences as c
				on c.ConferenceID = cd.ConferenceID
		where dr.ReservationID = @reservationID
		union all
		select concat('Konferencja: ', c.ConferenceName, ', Data: ',
			cd.ConferenceDate, ' - ', 'Liczba biletów studenckich: ', dr.StudentTickets)
				as ReservationInfo
		from DayReservation as dr
			inner join ConferenceDay as cd
				on cd.ConferenceDayID = dr.ConferenceDayID
			inner join Conferences as c
				on c.ConferenceID = cd.ConferenceID
		where dr.ReservationID = @reservationID
		union all
		select concat('Warsztat: ', wd.WorkshopName, ', Data: ',
			cd.ConferenceDate, ' - ', 'Liczba biletów: ', wr.Tickets)
				as ReservationInfo
		from DayReservation as dr
			inner join ConferenceDay as cd
				on cd.ConferenceDayID = dr.ConferenceDayID
			inner join WorkshopReservation as wr
				on wr.DayReservationID = dr.DayReservationID
			inner join Workshop as w
				on w.WorkshopID = wr.WorkshopID
			inner join WorkshopDictionary as wd
				on wd.WorkshopDictionaryID = w.WorkshopDictionaryID
			where dr.ReservationID = @reservationID
        union all
		select Concat('Cena: ',
		    sum(dr.NormalTickets*dbo.function_returnNormalTicketCost(@reservationID))
            +
            sum(dr.StudentTickets*dbo.function_returnStudentTicketCost(@reservationID))
		    +
            sum(isnull(wr.Tickets*w.Price, 0))) as ReservationInfo
        from DayReservation as dr
            left outer join WorkshopReservation wr
                    on dr.DayReservationID = wr.DayReservationID
	        left outer join Workshop w
	            on wr.WorkshopID = w.WorkshopID
        where dr.ReservationID = @reservationID
    )
go

