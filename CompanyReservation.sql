create procedure procedure_addCompanyReservation
    @ClientID int,
    @ConferenceID int,
    @DayList CompanyReservation READONLY,
    @StudentList StudentIDCards READONLY
as
begin
    set nocount on
    begin try
        begin tran addCompanyReservation
            if (@ClientID is null or @ConferenceID is null)
            begin
                ;throw 52000, 'All arguments are compulsory', 1
            end

            if not exists(select * from Clients where ClientID = @ClientID)
		    begin
                ;throw 52000, 'Client does not exists', 1
            end

            if not exists(select * from Clients as c inner join Company C2 on c.ClientID = C2.ClientID where c.ClientID = @ClientID)
		    begin
                ;throw 52000, 'Client is not Company', 1
            end

            if not exists(select * from Conferences where ConferenceID = @ConferenceID)
		    begin
                ;throw 52000, 'Conference does not exists', 1
            end

            --sprawdzam czy student nie jest wpisany 2 razy na ten sam dzien
            if exists(
                select sl1.StudentIDCard, sl2.ConferenceDate, count(sl2.ConferenceDate)
                from (select distinct StudentIDCard from @StudentList) as sl1
                inner join @StudentList as sl2 on sl1.StudentIDCard = sl2.StudentIDCard
                group by  sl1.StudentIDCard, sl2.ConferenceDate
                having  count(sl2.ConferenceDate) <> 1
            )
            begin
                ;throw 52000, 'Student is signed 2 times for one day', 1
            end

            declare @numberOfDays int = (select count(*) from @DayList);
            if (@numberOfDays <= 0)
            begin
                ;throw 52000, 'DayList cannot be empty', 1
            end

            insert into Reservation(
                ClientID,
                ReservationDate
            ) VALUES (@ClientID, GETDATE())
            declare @ReservationID int = @@IDENTITY


            declare @Date date;
            declare @ConferenceDayID int;
            declare @NormalTickets int;
            declare @StudentTickets int;
            declare @DayReservationID int;
            declare @NumberOfStudents int = (select count(*) from @StudentList);
            declare @StudentDate date;
            declare @StudentIDCard  varchar(50);

            declare @iterator1 int = 1;
            declare @iterator2 int;
            while (@iterator1 <= @numberOfDays)
            begin
                set @Date = (select ConferenceDate from @DayList where ID = @iterator1)
                set @conferenceDayID = dbo.function_returnConferenceDay (@ConferenceID, @Date);
                if (@ConferenceDayID is null)
                begin
                    ;throw 52000, 'Conference day does not exist', 1
                end
                set @NormalTickets = (select NormalTickets from @DayList where ID = @iterator1);
                if (@NormalTickets <= 0)
                begin
                    ;throw 52000, 'Number of tickets is invalid', 1
                end
                set @studentTickets = (select count(*) from @StudentList where ConferenceDate = @date);
/*wrocic*/      exec procedure_addCompanyDayReservation @ReservationID, @conferenceDayID, @normalTickets, @StudentTickets
                set @DayReservationID = @@IDENTITY;

                --dodaje studentow do danego dnia
                if (@StudentTickets > 0)
                begin
                    set @iterator2 = 1;
                    while(@iterator2 <= @NumberOfStudents)
                    begin
                        set @studentDate = (select ConferenceDate from @StudentList where ID = @iterator2);
                        if not exists (select * from @DayList where ConferenceDate = @studentDate)
                        begin
                            ;throw 52000, 'Invalid student date', 1
                        end
                        set @StudentIDCard = (select StudentIDCard from @StudentList where ConferenceDate = @date and ID = @iterator2);
                        exec procedure_initializeEmployee @ClientID,  @StudentIDCard
                        set @iterator2 = @iterator2 + 1;
                    end
                end

                set @iterator1 = @iterator1 + 1;
            end

        commit tran addCompanyReservation
    end try
    begin catch
        rollback tran addCompanyReservation
        declare @errorMessage nvarchar(2048)
			= 'Cannot add Reservation. Error message: '+ error_message();
		;throw 52000, @errorMessage, 1
    end catch
end
go

create procedure procedure_initializeEmployee
    @ClientID int,
    @StudentIDCard varchar(50)
as
begin
    set nocount on
    begin try
        if (@ClientID is null)
        begin
            ;throw 52000, 'ClientID is compulsory', 1
        end
        insert Person default values
        declare @PersonID int = @@IDENTITY
        insert into Employee(ClientID, PersonID, FirstName, LastName)
        VALUES(@ClientID, @PersonID, null, null)
        if (@StudentIDCard is not null)
        begin
            if not exists(select * from Student where StudentCardID = @StudentIDCard)
            begin
                insert into Student(StudentCardID, PersonID)
                Values (@StudentIDCard, @PersonID)
            end
        end
    end try
    begin catch
        declare @errorMessage nvarchar(2048)
			= 'Cannot initialize Employee. Error message: '+ error_message();
		;throw 52000, @errorMessage, 1
    end catch
end

create procedure procedure_addWorkshopCompanyReservation
    @ClientID int,
    @WorkshopID int,
    @NormalTickets int
as
begin
    set nocount on
    begin try
    begin tran addWorkshopCompanyReservation

        if (@WorkshopID is null or @ClientID is null or @NormalTickets is null)
        begin
            ;throw 52000, 'All arguments are compulsory', 1
        end

        if not exists(select * from Workshop where WorkshopID = @WorkshopID)
        begin
            ;throw 52000, 'Workshop does not exist', 1
        end

        if not exists(select * from Clients where ClientID = @ClientID)
        begin
            ;throw 52000, 'Client does not exist', 1
        end

        if not exists(select * from Company where @ClientID = ClientID)
        begin
            ;throw 52000, 'Client is not company', 1
        end
        declare @ConferenceDayID int = (select ConferenceDayID from Workshop where WorkshopID = @WorkshopID)

        if not exists (select DayReservationID from DayReservation DR
            inner join Reservation AS R on R.ReservationID = DR.ReservationID
            where DR.ConferenceDayID = @ConferenceDayID and R.ClientID = @ClientID)
        begin
            ;throw 52000, 'User has to book Conference to book a workshop', 1
        end

        declare @DayReservationID int = (select DayReservationID from DayReservation DR
            inner join Reservation AS R on R.ReservationID = DR.ReservationID
            where DR.ConferenceDayID = @ConferenceDayID and R.ClientID = @ClientID)

        insert into WorkshopReservation(
            WorkshopID, DayReservationID, Tickets
        )  VALUES (
            @WorkshopID, @DayReservationID, @NormalTickets
        )
    commit tran addWorkshopCompanyReservation
    end try
    begin catch
        rollback tran addWorkshopCompanyReservation
        declare @errorMessage nvarchar(2048)
            = 'Cannot addReservation. Error message: '
            + error_message();
        ;throw 52000, @errorMessage, 1
    end catch
end
go
