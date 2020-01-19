

declare @numberOfDayReservations int = (select count(*) from DayReservation)
declare @mainIterator int = 1;
while (@mainIterator <= @numberOfDayReservations)
begin
    declare @DayReservationID int = (select DayReservationID from DayReservation where DayReservationID = @mainIterator)
    declare @NormalTickets int = (select NormalTickets from DayReservation where DayReservationID = @mainIterator)
    declare @StudentTickets int = (select StudentTickets from DayReservation where DayReservationID = @mainIterator)
    declare @ClientID int = (select ClientID from DayReservation inner join Reservation R2 on DayReservation.ReservationID = R2.ReservationID where @DayReservationID = DayReservationID)

    declare @StudentTicketsList table (ID int identity (1,1), PersonID int)
    delete from @StudentTicketsList where ID <> 0
    insert into @StudentTicketsList(PersonID)
    select P.PersonID from Employee inner join Person P on Employee.PersonID = P.PersonID inner join Student S on P.PersonID = S.PersonID where ClientID = @ClientID

    declare @NormalTicketsList table (ID int identity (1,1), PersonID int)
    delete from @NormalTicketsList where ID <> 0
    insert into @NormalTicketsList(PersonID)
    (select PersonID from Employee where ClientID = @ClientID) except (select PersonID from @StudentTicketsList)
    declare @PersonID int;
    declare @iterator2 int = (select min(ID) from @StudentTicketsList)
    while (@iterator2 <= @StudentTickets + (select min(ID) from @StudentTicketsList) - 1)
    begin
        set @PersonID = (select PersonID from @StudentTicketsList where ID = @iterator2)
        insert into DayParticipant (PersonID, DayReservationID)
        VALUES (@PersonID, @DayReservationID)
        set @iterator2 = @iterator2 + 1;
    end

    set @iterator2 = (select min(ID) from @NormalTicketsList)
    while (@iterator2 <= @NormalTickets + (select min(ID) from @NormalTicketsList) - 1)
    begin
        set @PersonID = (select PersonID from @NormalTicketsList where ID = @iterator2)
        insert into DayParticipant (PersonID, DayReservationID)
        VALUES (@PersonID, @DayReservationID)
        set @iterator2 = @iterator2 + 1;
    end
    set @mainIterator = @mainIterator + 1;
end
