select * from view_companiesYetToFillEmployees

select * from view_workshopsSeatLeft

--confID
select * from function_showFreeSeatsForConference (1)

--reservationID
select * from function_reservationSummary (1)

--clientID
select * from function_showUnpaidReservations (1)

--confID
select * from function_workshopsDuringConference (1)

--confID, startDate,discount
exec procedure_addPriceThreshold

select * from Reservation  as r
    inner join DayReservation DR on r.ReservationID = DR.ReservationID
where r.ClientID = 2201

select * from function_showUnpaidReservations (2201)