    declare @numberOfReservations int = (select count(*) from Reservation)
    declare @numberOfConferences int = (select count(*) from Conferences)


    declare @mainIterator int = 1;
    while (@mainIterator <=@numberOfReservations)
    begin
        --pobieram losowa konferencje
        declare @ConferenceID int = ABS(CHECKSUM(NewId())) % @numberOfConferences + 1;
        declare @ReservationID int = @mainIterator;
        declare @ClientID int = (select ClientID from Reservation where ReservationID = @ReservationID)

        --sprawdzam czy uzytkownik rezerwowal juz dana konferencje
        if exists (select * from Reservation
            inner join DayReservation D on Reservation.ReservationID = D.ReservationID
            inner join ConferenceDay CD2 on D.ConferenceDayID = CD2.ConferenceDayID
            where @ClientID = ClientID and ConferenceID = @ConferenceID)
        begin
            delete from Reservation where ReservationID = @ReservationID
            set @mainIterator = @mainIterator + 1;
            continue;
        end

        --sprawdzam czy dana konferencja ma dni w których pozostają wolne miejsca
        declare @ConferenceDays table (ID int identity (1,1), ConferenceDayID int, limit int, total int)
        delete from @ConferenceDays where ID <> 0

        insert into @ConferenceDays ( ConferenceDayID, Limit, Total)
        select CD.ConferenceDayID, Limit, sum(isnull(NormalTickets, 0)) +
            sum(isnull(StudentTickets, 0))
        from ConferenceDay CD
            inner join Conferences C on CD.ConferenceID = C.ConferenceID
            left outer join DayReservation DR on CD.ConferenceDayID = DR.ConferenceDayID
        where C.ConferenceID = @ConferenceID
        group by C.ConferenceID, CD.ConferenceDayID, Limit
        having Limit > sum(isnull(NormalTickets, 0)) + sum(isnull(StudentTickets, 0))

        if not exists (select * from @ConferenceDays)
        begin
            delete from Reservation where ReservationID = @ReservationID
            set @mainIterator = @mainIterator + 1;
            continue;
        end

        --sprawdzam czy client to firma i licze ile jest normalnych userow i ile jest studentow przypisanych do clienta
        declare @isClientCompany bit;
        if exists (select * from Company where ClientID = @ClientID)
        begin
            set @isClientCompany = 1;
            declare @numberOfRegisteredStudents int = (select count (*) from Employee
            inner join Person P on Employee.PersonID = P.PersonID
            inner join Student S on P.PersonID = S.PersonID
            where ClientID = @ClientID)
            declare @numberOfRegisteredNormals int = (select count(*) from Employee where ClientID = @ClientID) - @numberOfRegisteredStudents
        end
        else
        begin
            set @isClientCompany = 0;
            if exists(select * from IndividualClient
                inner join Person P2 on IndividualClient.PersonID = P2.PersonID
                inner join Student S2 on P2.PersonID = S2.PersonID
                where ClientID = @ClientID)
                set @numberOfRegisteredStudents = 1;
            else
                set @numberOfRegisteredStudents = 0;

            set @numberOfRegisteredNormals = 1 - @numberOfRegisteredStudents
        end

        declare @iterator1 int = (select min(ID) from @ConferenceDays);
        while (@iterator1 <= (select max(ID) from @ConferenceDays))
        begin
            declare @limit int = (select Limit - total from @ConferenceDays where ID = @iterator1)
            declare @ConferenceDayID int = (select ConferenceDayID from @ConferenceDays where ID = @iterator1)
            declare @normalTickets int;
            declare @studentTickets int;
            if (@limit < @numberOfRegisteredNormals)
                set @normalTickets = @limit;
             else
                set @normalTickets = @numberOfRegisteredNormals

            if (@limit - @normalTickets < @numberOfRegisteredStudents)
                set @studentTickets = @limit - @normalTickets
            else
                set @studentTickets = @numberOfRegisteredStudents

            insert into DayReservation(ConferenceDayID, ReservationID, NormalTickets, StudentTickets)
            VALUES (@ConferenceDayID, @ReservationID, @normalTickets, @studentTickets)
            set @iterator1 = @iterator1 + 1;
        end

        --to moze nie dzialc do konca dobrze :(
        declare @ConferenceDate date = (select TOP 1 StartDate from Reservation
            inner join DayReservation DR2 on Reservation.ReservationID = DR2.ReservationID
            inner join ConferenceDay CD3 on DR2.ConferenceDayID = CD3.ConferenceDayID
            inner join Conferences C2 on CD3.ConferenceID = C2.ConferenceID
            where DR2.ReservationID = @ReservationID)
        declare @PaymentDate date = DateAdd(d, ROUND(DateDiff(d, '2017-01-01', @ConferenceDate) * RAND(CHECKSUM(NEWID())), 0),
      DATEADD(second,CHECKSUM(NEWID())%48000, '2017-01-01'))
        declare @ReservationDate date = DATEADD(week,-1,@PaymentDate)
        update Reservation
        set PaymentDate = @PaymentDate, ReservationDate = @ReservationDate
        where ReservationID = @ReservationID
        set @mainIterator = @mainIterator + 1;
    end






