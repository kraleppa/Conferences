
--blokuje mozliwosc zrobeninia 2 rezerwacji przez tego samego clienta na jedna konferencje
create trigger trigger_conferenceReservationAlreadyExists
    on DayReservation
    after insert
as
begin
    set nocount on
    declare @reservationID int = (select ReservationID from inserted)
    declare @clientID int = (select ClientID from inserted as i
        inner join Reservation as R on R.ReservationID = i.ReservationID)
    declare @conferenceID int = (select TOP 1 ConferenceID from inserted as i
        inner join ConferenceDay as CD on CD.ConferenceDayID = i.ConferenceDayID)
    if exists(
            select * from Reservation as R
            inner join DayReservation DR on R.ReservationID = DR.ReservationID
            inner join ConferenceDay CD on DR.ConferenceDayID = CD.ConferenceDayID
            where ConferenceID = @conferenceID and ClientID = @clientID and R.ReservationID != @reservationID
        )
        begin
            ;throw 50001, 'User has already booked this Conference', 1
        end
end
go
--blokuje mozliwosc dokonania rezerwacji konferencji jezeli uzytkownik probuje przekoroczyc limit

create trigger trigger_conferenceReservationLimit
    on DayReservation
    after insert
as
begin
    set nocount on
    declare @conferenceID int = (select TOP 1 ConferenceID from inserted as i
        inner join ConferenceDay as CD on CD.ConferenceDayID = i.ConferenceDayID)
    declare @dayLimit int = (select Limit from Conferences where ConferenceID = @conferenceID)

   if exists(
            select CD.ConferenceDayID, isnull(sum(DR.StudentTickets) + sum(DR.NormalTickets), 0)
            from ConferenceDay as CD
                    inner join DayReservation DR on CD.ConferenceDayID = DR.ConferenceDayID
                    inner join inserted i on i.ConferenceDayID = CD.ConferenceDayID
            where CD.ConferenceID = @conferenceID
            group by CD.ConferenceDayID
            having isnull(sum(DR.StudentTickets) + sum(DR.NormalTickets), 0) > @dayLimit
    )
    begin
        ;throw 50001, 'Too few free places to book day', 1
    end
end
go
--blokuje mozliwosc zarezerwowania warsztatu wiecej niz raz przez tego samego klienta
create trigger trigger_workshopReservationAlreadyExists
    on WorkshopReservation
    after insert
as
    begin
        set nocount on
        declare @dayReservationID int = (select DayReservationID from inserted)
        declare @workshopID int = (select WorkshopID from inserted)
        declare @workshopReservationID int = (select WorkshopReservationID from inserted)
        if exists (
            select * from WorkshopReservation
            where DayReservationID = @dayReservationID
                and WorkshopID = @workshopID
                and WorkshopReservationID != @workshopReservationID
        )
        begin
            ;throw 50001, 'Client has already booked this Workshop', 1
        end
    end
go
--blokuje mozliwosc zarezerwowania warsztatu jezeli limit ma zostac przekorczony
create trigger trigger_workshopReservationLimit
    on WorkshopReservation
    after insert
as
    begin
        set nocount on
        declare @WorkshopID int = (select WorkshopID from inserted)
        declare @limit int = (select Limit from Workshop where Workshop.WorkshopID = @WorkshopID)
        if exists(
            select sum(WR.Tickets)
            from WorkshopReservation as WR
            where WR.WorkshopID = @WorkshopID
            group by WR.WorkshopID
            having sum(WR.Tickets) > @limit
        )
        begin
            ;throw 50001, 'Too few places to book workshop', 1
        end
    end
go
--blokuje mozliwosc zarezerwowania warsztatu jezeli osobie nachodza sie warsztaty
create trigger trigger_participantTakesPartInOverlappingWorkshops
    on WorkshopParticipant
    after insert
as
    begin
        set nocount on
        declare @WorkshopReservationID int = (select WorkshopReservationID from inserted)
        declare @DayParticipantID int = (select DayParticipantID from inserted)
        declare @WorkshopID int = (
            select WR.WorkshopID from WorkshopReservation as WR
                inner join Workshop W on WR.WorkshopID = W.WorkshopID
                where WR.WorkshopReservationID = @WorkshopReservationID
        )
        declare @StartTime time = (select StartTime from Workshop where WorkshopID = @WorkshopID)
        declare @EndTime time = (select EndTime from Workshop where WorkshopID = @WorkshopID)
        if exists(
            select * from DayParticipant AS DP
                inner join WorkshopParticipant WP on DP.DayParticipantID = WP.DayParticipantID
                inner join WorkshopReservation WR on WP.WorkshopReservationID = WR.WorkshopReservationID
                inner join Workshop W on WR.WorkshopID = W.WorkshopID
                where DP.DayParticipantID = @DayParticipantID and W.WorkshopID != @WorkshopID
                    and (
                        (W.StartTime < @StartTime and  W.EndTime > @StartTime )
                    or ( W.StartTime > @StartTime and W.StartTime < @EndTime)
                    or (W.StartTime > @StartTime and  W.EndTime < @EndTime)
                    or (W.StartTime < @StartTime and W.EndTime > @EndTime)
                    )
        )
        begin
            ;throw 50001, 'Workshops are overlapping', 1
        end
    end
go

create trigger trigger_deleteDayReservationAfterDeletingReservation
    on Reservation
    after delete
as
    begin
        set nocount on
        Delete from DayReservation
            where ReservationID IN (
                select ReservationID from deleted
        )
    end
go

create trigger trigger_deleteDayParticipantAfterDeletingDayReservation
    on DayReservation
    after delete
as
    begin
        set nocount on
        delete from DayParticipant
            where DayReservationID in (
                    select DayReservationID from deleted
                )
    end
go

create trigger trigger_deleteNULLEmployeeAfterDeletingDayParticipant
    on DayParticipant
    after delete
as
    begin
        set nocount on
        delete from Employee
            where PersonID in (
                select PersonID from deleted
            ) and FirstName is null and LastName is null
    end
go

create trigger trigger_deletePersonAfterDeletingNULLEmployees
    on Employee
    after delete
as
    begin
        set nocount on
        delete from Person
        where PersonID in (
            select PersonID from deleted
        )
    end
go

create trigger trigger_deleteStudentAfterDeletingPerson
    on Person
    after delete
as
    begin
        set nocount on
        delete from Student
        where PersonID in (
                select PersonID from deleted
        )
    end
go

create trigger trigger_deleteWorkshopReservationAfterDeletingDayReservation
    on DayReservation
    after delete
as
    begin
        set nocount on
        Delete from WorkshopReservation
            where DayReservationID in(
                select DayReservationID from deleted
            )
    end
go


create trigger trigger_deleteWorkshopParticipantsAfterDeletingWorkshopReservation
    on WorkshopReservation
    after delete
as
    begin
        set nocount on
        Delete from WorkshopParticipant
            where WorkshopReservationID in (
                select WorkshopReservationID from deleted
            )
    end
go


