declare @numberOfDayReservations int = (select count(*) from DayReservation)

declare @mainIterator int = 1;

while (@mainIterator <= @numberOfDayReservations)
begin
    declare @ConferenceDayID int = (select ConferenceDayID from DayReservation where DayReservationID = @mainIterator)
    declare @DayReservationID int = (select DayReservationID from DayReservation where DayReservationID = @mainIterator)
    declare @TicketsSum int = (select NormalTickets + StudentTickets from DayReservation where DayReservationID = @mainIterator)

    declare @DayWorkshops table (ID int identity (1,1), WorkshopID int, Limit int, Total int)
    delete from @DayWorkshops where ID <> 0
    insert into @DayWorkshops(WorkshopID, limit, Total)
    select Workshop.WorkshopID, Limit, sum(isnull(Tickets, 0)) from Workshop
    left outer join WorkshopReservation WR on Workshop.WorkshopID = WR.WorkshopID
    where ConferenceDayID = @ConferenceDayID
    group by Workshop.WorkshopID, Limit
    having Limit > sum(isnull(Tickets, 0))

    if not exists (select * from @DayWorkshops)
    begin
        set @mainIterator = @mainIterator + 1;
        continue;
    end
    declare @randomID int = ABS(CHECKSUM(NewId())) % ((select max(ID) from @DayWorkshops) + 1 - (select min(id) from @DayWorkshops)) + (select min(id) from @DayWorkshops)
    declare @WorkshopID int = (select WorkshopID from @DayWorkshops where ID = @randomID)
    declare @emptySpaces int = (select Limit - Total from @DayWorkshops where ID = @randomID)
    if (@emptySpaces < @TicketsSum)
        insert into WorkshopReservation(WorkshopID, DayReservationID, Tickets) VALUES (@WorkshopID, @DayReservationID, @emptySpaces)
    else
        insert into WorkshopReservation(WorkshopID, DayReservationID, Tickets) VALUES (@WorkshopID, @DayReservationID, @TicketsSum)
    set @mainIterator = @mainIterator + 1;
end
