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
		where conf.ConferenceID = @conf_id
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

		select top(@x) with ties c.ClientID, ic.FirstName, ic.LastName,
			count(r.ReservationID) as 'Liczba oplaconych rezerwacji'

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
		select top(@x) with ties com.CompanyName,
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

		select top(1) with ties com.CompanyName,
			count(r.ReservationID) as 'Liczba oplaconych rezerwacji'

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



--zwraca list� rezerwacji ktore nie zostaly oplacone oraz czas jaki pozostal


create function function_unpaidReservations(@ClientID int)
	returns table
	as
	return (
		select ReservationID, 
			DATEDIFF(day, GETDATE(), DATEADD(day, 7, ReservationDate)) as 'Days left'
		from Reservation 
		where ClientID = @ClientID
			and PaymentDate is null
	)
go


--zwraca cene normalnego biletu w danej rezerwacji
create function function_returnNormalTicketCost(@reservationID int)
	returns int
	as
	begin
	    declare @reservationDate date = (
            select ReservationDate
            from Reservation
            where ReservationID = @reservationID
        )
		return (
			select c.BasePrice*(1-isnull(p.Discount, 0))
			from Conferences as c
				left outer join Prices as p
					on p.ConferenceID = c.ConferenceID and 
						p.StartDate in (
						    select p2.StartDate
						    from Prices as p2
						    where p2.ConferenceID = c.ConferenceID
						    group by p2.StartDate
                            having min(datediff(d, StartDate, @reservationDate)) >= 0
                        )
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
	    declare @reservationDate date = (
            select ReservationDate
            from Reservation
            where ReservationID = @reservationID
        )
		return (
			select c.BasePrice*(1-isnull(p.Discount, 0))*(1-c.StudentDiscount)
			from Conferences as c
				left outer join Prices as p
					on p.ConferenceID = c.ConferenceID and 
						p.StartDate in (
						    select p2.StartDate
						    from Prices as p2
						    where p2.ConferenceID = c.ConferenceID
						    group by p2.StartDate
                            having min(datediff(d, StartDate, @reservationDate)) >= 0
                        )
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
create function function_reservationSummary(@reservationID int)
	returns table
	as
	return (
		select concat('Konferencja: ', c.ConferenceName, ', Data: ',

			cd.ConferenceDate, ' - ', 'Liczba biletow normalnych: ', dr.NormalTickets)

				as ReservationInfo
		from DayReservation as dr
			inner join ConferenceDay as cd
				on cd.ConferenceDayID = dr.ConferenceDayID
			inner join Conferences as c
				on c.ConferenceID = cd.ConferenceID
		where dr.ReservationID = @reservationID
		union all
		select concat('Konferencja: ', c.ConferenceName, ', Data: ',

			cd.ConferenceDate, ' - ', 'Liczba biletow studenckich: ', dr.StudentTickets)

				as ReservationInfo
		from DayReservation as dr
			inner join ConferenceDay as cd
				on cd.ConferenceDayID = dr.ConferenceDayID
			inner join Conferences as c
				on c.ConferenceID = cd.ConferenceID
		where dr.ReservationID = @reservationID
		union all
		select concat('Warsztat: ', wd.WorkshopName, ', Data: ',

			cd.ConferenceDate, ' - ', 'Liczba biletow: ', wr.Tickets)

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


--generowanie faktury dla klienta indywidualnego
create function function_generateIndividualInvoice(@reservationID int)
    returns table
    as
    return (

        select concat('Rezerwujacy: ', ic.FirstName, ' ' , ic.LastName) as Faktura

        from Reservation as r
            inner join Clients C
                on r.ClientID = C.ClientID
            inner join IndividualClient IC
                on C.ClientID = IC.ClientID
        where r.ReservationID = @reservationID
        union all
        select concat('Data rezerwacji: ', r.ReservationDate)
        from Reservation as r
        where r.ReservationID = @reservationID
        union all

        select concat('Data platnosci: ', r.PaymentDate)

        from Reservation as r
        where r.ReservationID = @reservationID
        union all
        select Concat('Kwota: ',
		    sum(dr.NormalTickets*dbo.function_returnNormalTicketCost(@reservationID))
            +
            sum(dr.StudentTickets*dbo.function_returnStudentTicketCost(@reservationID))
		    +
            sum(isnull(wr.Tickets*w.Price, 0))) as Faktura
        from DayReservation as dr
            left outer join WorkshopReservation wr
                    on dr.DayReservationID = wr.DayReservationID
	        left outer join Workshop w
	            on wr.WorkshopID = w.WorkshopID
        where dr.ReservationID = @reservationID
        union all
        select '-----------------------------------'
        union all

        select 'Szczegoly'

        union all
        select ''
        union all
        select distinct concat('Konferencja: ', C2.ConferenceName) as Faktura
        from DayReservation as DR
            inner join ConferenceDay CD
                on DR.ConferenceDayID = CD.ConferenceDayID
            inner join Conferences C2
                on CD.ConferenceID = C2.ConferenceID
        where DR.ReservationID = @reservationID
        union all
        select concat('Cena biletu normalnego (N): ',
            dbo.function_returnNormalTicketCost(@reservationID)) as Faktura
        union all
        select concat('Cena biletu studenckiego (S): ',
            dbo.function_returnStudentTicketCost(@reservationID)) as Faktura
        union all

        select concat('Dzien konferencji: ', CD.ConferenceDate,

            ', N: ', dr.NormalTickets, ', S: ', dr.StudentTickets, ', Cena: ',
            dr.NormalTickets*dbo.function_returnNormalTicketCost(@reservationID)
            +
            dr.StudentTickets*dbo.function_returnStudentTicketCost(@reservationID)) as Faktura
        from DayReservation as dr
            inner join ConferenceDay CD
                on dr.ConferenceDayID = CD.ConferenceDayID
        where dr.ReservationID = @reservationID
        union all
        select 'Zarezerwowane warsztaty w ramach koferencji' as Faktura
        union all

        select concat(WD.WorkshopName, ', Dzien: ', CD.ConferenceDate, ', ',

            W.StartTime, ' - ', W.EndTime ,', Cena: ', wr.Tickets*W.Price) as Faktura
        from DayReservation as dr
           left outer join WorkshopReservation WR
               on dr.DayReservationID = WR.DayReservationID
           left outer join Workshop W
               on WR.WorkshopID = W.WorkshopID
           left outer join WorkshopDictionary WD
               on W.WorkshopDictionaryID = WD.WorkshopDictionaryID
            inner join ConferenceDay CD
                on W.ConferenceDayID = CD.ConferenceDayID
        where dr.ReservationID = @reservationID
    )
go


--generowanie faktury dla firmy
create function function_generateCompanyInvoice(@reservationID int)
    returns table
    as
    return (

        select concat('Rezerwujacy: ', C3.CompanyName) as Faktura

        from Reservation as r
            inner join Clients C
                on r.ClientID = C.ClientID
            inner join Company C3
                on C.ClientID = C3.ClientID
        where r.ReservationID = @reservationID
        union all
        select concat('Data rezerwacji: ', r.ReservationDate)
        from Reservation as r
        where r.ReservationID = @reservationID
        union all

        select concat('Data platnosci: ', r.PaymentDate)

        from Reservation as r
        where r.ReservationID = @reservationID
        union all
        select Concat('Kwota: ',
		    sum(dr.NormalTickets*dbo.function_returnNormalTicketCost(@reservationID))
            +
            sum(dr.StudentTickets*dbo.function_returnStudentTicketCost(@reservationID))
		    +
            sum(isnull(wr.Tickets*w.Price, 0))) as Faktura
        from DayReservation as dr
            left outer join WorkshopReservation wr
                    on dr.DayReservationID = wr.DayReservationID
	        left outer join Workshop w
	            on wr.WorkshopID = w.WorkshopID
        where dr.ReservationID = @reservationID
        union all
        select '-----------------------------------'
        union all
        select ''
        union all
        select distinct concat('Konferencja: ', C2.ConferenceName) as Faktura
        from DayReservation as DR
            inner join ConferenceDay CD
                on DR.ConferenceDayID = CD.ConferenceDayID
            inner join Conferences C2
                on CD.ConferenceID = C2.ConferenceID
        where DR.ReservationID = @reservationID
        union all
        select concat('Cena biletu normalnego (N): ',
            dbo.function_returnNormalTicketCost(@reservationID)) as Faktura
        union all
        select concat('Cena biletu studenckiego (S): ',
            dbo.function_returnStudentTicketCost(@reservationID)) as Faktura
        union all
        select ''
        union all

        select concat('Dzien konferencji: ', CD.ConferenceDate,
                      ', N: ', dr.NormalTickets, ', S: ', dr.StudentTickets, ', Cena: ',

            dr.NormalTickets*dbo.function_returnNormalTicketCost(@reservationID)
            +
            dr.StudentTickets*dbo.function_returnStudentTicketCost(@reservationID)) as Faktura
        from DayReservation as dr
            inner join ConferenceDay CD
                on dr.ConferenceDayID = CD.ConferenceDayID
        where dr.ReservationID = @reservationID
        union all
        select ''
        union all
        select 'Bilet normalny'
        union all

        select concat('Dzien konferencji: ', cd.ConferenceDate, ', ',
                      E.FirstName, ' ', e.LastName) as Faktura

        from DayReservation as dr
            inner join ConferenceDay CD
                on dr.ConferenceDayID = CD.ConferenceDayID
            inner join DayParticipant DP
                on dr.DayReservationID = DP.DayReservationID
            inner join Person P
                on DP.PersonID = P.PersonID
            inner join Employee E
                on P.PersonID = E.PersonID
        where dr.ReservationID = @reservationID and
              p.PersonID not in (select Student.PersonID from Student)
        union all
        select ''
        union all
        select 'Bilet studencki'
        union all

            select concat('Dzien konferencji: ', cd.ConferenceDate, ', ',
                          E.FirstName, ' ', e.LastName) as Faktura

        from DayReservation as dr
            inner join ConferenceDay CD
                on dr.ConferenceDayID = CD.ConferenceDayID
            inner join DayParticipant DP
                on dr.DayReservationID = DP.DayReservationID
            inner join Person P
                on DP.PersonID = P.PersonID
            inner join Employee E
                on P.PersonID = E.PersonID
        where dr.ReservationID = @reservationID and
              p.PersonID in (select Student.PersonID from Student)
        union all
        select ''
        union all
        select 'Zarezerwowane warsztaty w ramach konferencji' as Faktura
        union all

        select concat(WD.WorkshopName, ', Dzien: ', CD.ConferenceDate, ', ',
                      W.StartTime, ' - ', W.EndTime , ', Cena: ', wr.Tickets*W.Price) as Faktura

        from DayReservation as dr
            left outer join WorkshopReservation WR
                   on dr.DayReservationID = WR.DayReservationID
            left outer join Workshop W
                on WR.WorkshopID = W.WorkshopID
            left outer join WorkshopDictionary WD
                on W.WorkshopDictionaryID = WD.WorkshopDictionaryID
            inner join ConferenceDay CD
                on W.ConferenceDayID = CD.ConferenceDayID
        where dr.ReservationID = @reservationID
        union all

        select concat(WD.WorkshopName, ', Dzien: ', CD.ConferenceDate, ', ',
                      W.StartTime, ' - ', W.EndTime , e2.FirstName, ' ', e2.LastName) as Faktura

        from DayReservation as dr
            left outer join WorkshopReservation WR
                on dr.DayReservationID = WR.DayReservationID
            inner join Workshop W
                on WR.WorkshopID = W.WorkshopID
            inner join WorkshopDictionary WD
                on W.WorkshopDictionaryID = WD.WorkshopDictionaryID
            inner join ConferenceDay CD
                on W.ConferenceDayID = CD.ConferenceDayID
            inner join WorkshopParticipant as wp
                on wp.WorkshopReservationID = wr.WorkshopReservationID
            inner join DayParticipant as dp
                on wp.DayParticipantID = dp.DayParticipantID
            inner join Person P2
                on dp.PersonID = P2.PersonID
            inner join Employee E2
                on P2.PersonID = E2.PersonID
        where dr.ReservationID = @reservationID
    )
go


--zwraca nieoplacone rezerwacje klienta
create function function_showUnpaidReservations(@ClientID int)
    returns table
    as
    return (
        select r.ReservationID, r.ReservationDate,
               abs(7 - datediff(day, r.ReservationDate, getdate())) as 'days left',
               sum(dr.NormalTickets*dbo.function_returnNormalTicketCost(r.ReservationID))
               +
               sum(dr.StudentTickets*dbo.function_returnStudentTicketCost(r.ReservationID))
               as 'Kwota'
        from Reservation as r
            inner join DayReservation as dr
                on dr.ReservationID = r.ReservationID
        where r.ClientID = 1 and r.PaymentDate is null
        group by r.ReservationID, r.ReservationDate
    )
go


--wyswietla pracownikow firmy
create function function_showEmployees(@CompanyID int)
    returns table
    as
    return (
        select e.FirstName, e.LastName
        from Employee as e
            inner join Company C
                on e.ClientID = C.ClientID
        where c.ClientID = @CompanyID
    )
go
