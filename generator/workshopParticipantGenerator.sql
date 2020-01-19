declare @NumberOfWorkshopReservations int = (select count(*) from WorkshopReservation)

declare @mainIterator int = 1;
while (@mainIterator <= @NumberOfWorkshopReservations)
begin
    declare @WorkshopReservationsID int = (select WorkshopReservationID from WorkshopReservation where WorkshopReservationID = @mainIterator)
    declare @DayReservationID int = (select DayReservationID from WorkshopReservation where WorkshopReservationID = @mainIterator)
    declare @Tickets int = (select Tickets from WorkshopReservation where WorkshopReservationID = @mainIterator)

    declare @DayParticipantsList table (ID int identity (1,1), DayParticipantID int)
    delete from @DayParticipantsList where ID <> 0

    insert into @DayParticipantsList(DayParticipantID)
    select DayParticipantID from DayParticipant where DayReservationID = @DayReservationID

    declare @iterator1 int = (select min(ID) from @DayParticipantsList)
    while (@iterator1 <= @Tickets + (select min(ID) from @DayParticipantsList) - 1)
    begin
        declare @DayParticipantID int = (select DayParticipantID from @DayParticipantsList where ID = @iterator1)
        insert into WorkshopParticipant(DayParticipantID, WorkshopReservationID)
        VALUES (@DayParticipantID, @WorkshopReservationsID)
        set @iterator1 = @iterator1 + 1
    end
    set @mainIterator = @mainIterator + 1;
end

select * from WorkshopParticipant