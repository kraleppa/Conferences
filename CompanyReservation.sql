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

create procedure procedure_addCompanyEmployeeInformation
    @ClientID int,
    @ReservationID int,
    @NameList NamesTable READONLY,
    @ConferenceList ConferenceTable READONLY,
    @WorkshopList WorkshopTable READONLY
as
begin
    set nocount on
    begin try
        begin tran addCompanyEmployeeInformation

            if not exists(select * from Clients where ClientID = @ClientID)
            begin
                ;throw 52000, 'Client does not exist', 1
            end

            if not exists(select * from Company where ClientID = @ClientID)
            begin
                ;throw 52000, 'Client is not a company', 1
            end

            if not exists (
                select * from Reservation
                where  ClientID = @ClientID and ReservationID = @ReservationID
            )
            begin
                ;throw 52000, 'Reservation does not exist', 1
            end

            declare @ConferenceID int = (
                select TOP 1 ConferenceID from Reservation
                    inner join DayReservation DR on Reservation.ReservationID = DR.ReservationID
                    inner join ConferenceDay CD on DR.ConferenceDayID = CD.ConferenceDayID
                where Reservation.ReservationID = @ReservationID
            )

            declare @NameListLength int = (select count(*) from @NameList)
            declare @ConferenceListLength int = (select count(*) from @ConferenceList)
            declare @WorkshopListLength int = (select count(*) from @WorkshopList)

            declare @iterator1 int = 1;
            declare @StudentIDCard varchar(50);
            while (@iterator1 <= @NameListLength)
            begin
                set @StudentIDCard = (select Legitymacja from @NameList where IDOsoby = @iterator1)
                if (@StudentIDCard is not null)
                begin
                    if not exists(select * from Student where StudentCardID = @StudentIDCard)
                    begin
                        ;throw 52000, 'StudentIDCard does not exist in data base', 1
                    end
                end
                set @iterator1 = @iterator1 + 1;
            end

            set @iterator1 = 1;
            declare @IDOsoby int;
            declare @Data date;
            while (@iterator1 <= @ConferenceListLength)
            begin
                set @IDOsoby = (select IDOsoby from @ConferenceList where ID = @iterator1)
                if not exists(select * from @NameList where IDOsoby = @IDOsoby)
                begin
                    ;throw 52000, 'Argument table error', 1
                end

                set @Data = (select Data from @ConferenceList where ID = @iterator1)
                if (dbo.function_returnConferenceDay(@ConferenceID, @Data) is null)
                begin
                    ;throw 52000, 'Conference does not take place in this day', 1
                end

                set @iterator1 =  @iterator1 + 1;
            end

            set @iterator1 = 1;
            declare @WorkshopID int;
            while (@iterator1 <= @WorkshopListLength)
            begin
                set @IDOsoby = (select IDOsoby from @WorkshopList where ID = @iterator1)
                if not exists(select * from @NameList where IDOsoby = @IDOsoby)
                begin
                    ;throw 52000, 'Argument table error', 1
                end

                set @WorkshopID = (select WorkshopID from @WorkshopList where ID = @iterator1)
                if not exists (select * from Workshop
                    inner join ConferenceDay C on Workshop.ConferenceDayID = C.ConferenceDayID
                    where WorkshopID = @WorkshopID and ConferenceID = @ConferenceID
                )
                begin
                    ;throw 52000, 'Workshop does not exist', 1
                end
                set @iterator1 = @iterator1 + 1;
            end

            --zaczynam dodawac uczestnikow
            declare @FirstName varchar(50);
            declare @LastName varchar(50);
            declare @PersonID int;
            declare @ConferenceDayReservation int;
            declare @WorkshopReservation int;
            declare @DayParticipantID int;

            declare @iterator2 int;
            set @iterator1 = 1;
            while (@iterator1 <= @NameListLength)
            begin
                --aktualizuje informacje o pracownikach
                set @StudentIDCard = (select Legitymacja from @NameList where IDOsoby = @iterator1)
                set @FirstName = (select Imie from @NameList where IDOsoby = @iterator1)
                set @LastName = (select Nazwisko from @NameList where IDOsoby = @iterator1)
                set @IDOsoby = @iterator1;
                if (@StudentIDCard is null)
                begin
                    insert into Person default values
                    set @PersonID = @@IDENTITY;
                    insert into Employee(ClientID, PersonID, FirstName, LastName)
                    VALUES (@ClientID, @PersonID, @FirstName, @LastName)
                end
                else
                begin
                    set @PersonID = (select PersonID from Student where StudentCardID = @StudentIDCard)
                    update Employee
                    set FirstName = @FirstName, LastName = @LastName
                    where PersonID = @PersonID
                end

                --dodaje osobe do rezerwacji dnia
                set @iterator2 = 1;
                while (@iterator2 <= @ConferenceListLength)
                begin
                    if exists(select * from @ConferenceList where ID = @iterator2 and IDOsoby = @IDOsoby)
                    begin
                        set @Data = (select Data from @ConferenceList where ID = @iterator2 and IDOsoby = @IDOsoby)
                        set @ConferenceDayReservation = (select DayReservationID from DayReservation
                            inner join ConferenceDay D on DayReservation.ConferenceDayID = D.ConferenceDayID
                            where ReservationID = @ReservationID and ConferenceDate = @Data
                            )
                        insert into DayParticipant(PersonID, DayReservationID)
                        VALUES (@PersonID, @ConferenceDayReservation)
                    end
                    set @iterator2 = @iterator2 + 1;
                end

                --dodaje osobe do rezerwacji warsztatu
                set @iterator2 = 1;
                while (@iterator2 <= @WorkshopListLength)
                begin
                    if exists (select * from @WorkshopList where ID = @iterator2 and IDOsoby = @IDOsoby)
                    begin
                        set @WorkshopID = (select WorkshopID from @WorkshopList where ID = @iterator2 and IDOsoby = @IDOsoby)
                        set @WorkshopReservation = (select WorkshopReservationID from WorkshopReservation
                            inner join DayReservation DR2 on WorkshopReservation.DayReservationID = DR2.DayReservationID
                            where ReservationID = @ReservationID and WorkshopID = @WorkshopID
                            )
                        if not exists (select * from WorkshopReservation WR
                            inner join DayReservation DR3 on WR.DayReservationID = DR3.DayReservationID
                            inner join DayParticipant DP on DR3.DayReservationID = DP.DayReservationID
                            where ReservationID = @ReservationID and PersonID = @PersonID)
                        begin
                            ;throw 52000, 'User is not Day Participant', 1
                        end

                        set @DayParticipantID = (select DayParticipantID from WorkshopReservation WR
                            inner join DayReservation DR3 on WR.DayReservationID = DR3.DayReservationID
                            inner join DayParticipant DP on DR3.DayReservationID = DP.DayReservationID
                            where ReservationID = @ReservationID and PersonID = @PersonID)

                        insert into WorkshopParticipant(DayParticipantID, WorkshopReservationID)
                        VALUES (@DayParticipantID, @WorkshopReservation)
                    end
                    set @iterator2 = @iterator2 + 1;
                end

                set @iterator1 = @iterator1 + 1;
            end



        commit tran addCompanyEmployeeInformation
    end try
    begin catch
        rollback tran addCompanyEmployeeInformation
        declare @errorMessage nvarchar(2048)
            = 'Cannot add informations about employees. Error message: '
            + error_message();
        ;throw 52000, @errorMessage, 1
    end catch
end
go
