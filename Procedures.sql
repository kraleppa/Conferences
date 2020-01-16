--Procedures

create procedure procedure_addWorkshopToDictionary
	@WorkshopName varchar(50),
	@WorkshopDescription varchar(255),
	@Price money
as
begin
	set nocount on
	begin try
	    insert into WorkshopDictionary (
		    WorkshopName,
		    WorkshopDescription,
		    Price
	    )
	    VALUES (
		    @WorkshopName,
		    @WorkshopDescription,
		    @Price
	    )
	end try
	begin catch
		declare @errorMessage nvarchar(2048) =
		'Cannot add workshop. Error message: ' + ERROR_MESSAGE();
		;throw 52000, @errorMessage, 1;
	end catch
end
go


create procedure procedure_addWorkshop
	@WorkshopDictionaryID int,
    @Date date,
    @ConferenceID int,
	@StartTime time,
	@EndTime time,
	@Limit int
as
begin
	set nocount on
	begin try
	    Declare @ConferenceDayID int = dbo.function_returnConferenceDay(@ConferenceID, @Date);
		if  (@ConferenceDayID is null)
		begin
			;throw 52000, 'Conference day does not exist', 1
        end

		if not exists (
			select * from WorkshopDictionary
			where WorkshopDictionaryID = @WorkshopDictionaryID
		)
		begin
			;throw 52000, 'Workshop does not exist in dictionary',1
		end
		if (@StartTime > @EndTime)
		begin
			;throw 52000, 'Start time cannot be bigger than end time', 1
		end
		Declare @Price money = (select price from WorkshopDictionary where WorkshopDictionaryID = @WorkshopDictionaryID)

	insert into Workshop (
		WorkshopDictionaryID,
		ConferenceDayID,
		StartTime,
		EndTime,
		Limit,
		Price
		)
		VALUES (
			@WorkshopDictionaryID,
			@ConferenceDayID,
			@StartTime,
			@EndTime,
			@Limit,
			@Price
		)
	end try
	begin catch

		declare @errorMessage nvarchar(2048) =
		'Cannot add workshop. Error message: ' + ERROR_MESSAGE();
		;throw 52000, @errorMessage, 1;
	end catch
end
go


create procedure procedure_addCountry
	@countryName varchar(50)
as
begin
	set nocount on
	begin try
		if exists (
			select country
			from Country
			where Country = @countryName
		)
		begin
			;throw 52000, 'Country exists', 1
		end
		insert into Country (
			Country
		)
		values (
			@countryName
		)
	end try
	begin catch
		declare @errorMsg nvarchar(2048)
			= 'Cannot add country. Error message: '
			+ error_message();
		;throw 52000, @errorMsg, 1
	end catch
end 
go
	

create procedure procedure_addCity
	@cityName varchar(50),
	@countryName varchar(50)
as
begin
	set nocount on
	begin try
		if(@cityName is null or @countryName is null) 
			begin
				;throw 52000,  'All arguments are compulsory.', 1
			end 
		if not exists (
			select *
			from Country
			where Country = @countryName
		)
			begin
				exec procedure_addCountry 
						@countryName
			end
		if not exists (
			select * 
			from City
			where city = @cityName
		)
			begin
				insert into City (
					City,
					CountryID
				)
				values (
					@cityName,
					(
					select countryID
					from Country
					where Country = @countryName
					)
				)
			end
	end try
	begin catch 
		declare @errorMsg nvarchar(2048)
			= 'Cannot add city. Error message: '
			+ error_message();
		;throw 52000, @errorMsg, 1
	end catch
end
go


create procedure procedure_addConferenceDay
	@conferenceID int,
	@conferenceDate date
as
begin
	begin try
		if(@conferenceID is null or
		   @conferenceDate is null
		  )
			begin
				;throw 52000,  'All arguments are compulsory.', 1
			end

		insert into ConferenceDay (
			ConferenceID,
			ConferenceDate
		)
		values (
			@conferenceID,
			@conferenceDate
		)
	end try

	begin catch 
		declare @errorMsg nvarchar(2048)
			= 'Cannot add conference day. Error message: '
			+ error_message();
		;throw 52000, @errorMsg, 1
	end catch
end
go


create procedure procedure_addConference
	@conferenceName varchar(50),
	@conferenceDescription varchar(255),
	@startDate date,
	@endDate date,
	@cityName varchar(50),
	@countryName varchar(50),
	@street varchar(50),
	@buildingNumber varchar(10),
	@studentDiscount real,
	@limit int,
	@basePrice money
as
begin
	set nocount on
	begin try
        begin tran add_conference

		if (@conferenceName is null or
			@conferenceDescription is null or
			@startDate is null or
			@endDate is null or
			@cityName is null or
			@countryName is null or
			@street is null or
			@buildingNumber is null or
			@studentDiscount is null or
			@limit is null or
			@basePrice is null
		)
			begin
				;throw 52000,  'All arguments are compulsory.', 1
			end

		if (@startDate <= getdate())
			begin
				;throw 52000, 'Start date cannot be earlier than today', 1
			end

		if (@startDate >@endDate)
			begin
				;throw 52000, 'Start date has to bo earlier than end date', 1
			end

		if(@studentDiscount < 0 or @studentDiscount > 1)
			begin
				;throw 52000, 'Discount cannot be bigger than 1 and smaller than 0', 1
			end

		if not exists (
			select * 
			from City
			where City = @cityName and
				CountryID = (
					select CountryID
					from Country
					where Country = @countryName
				)
		)
			begin
				exec procedure_addCity
						@cityName,
						@countryName
			end

		begin
			insert into Conferences (
				ConferenceName,
				ConferenceDescription,
				StartDate,
				EndDate,
				CityID,
				Street,
				BuildingNumber,
				StudentDiscount,
				Limit,
				BasePrice
			)
			values (
				@conferenceName,
				@conferenceDescription,
				@startDate,
				@endDate,
				(
					 select CityID
					 from City
					 where city = @cityName and
						CountryID = (
						select CountryID
						from Country
						where Country = @countryName
					)
				),
				@street,
				@buildingNumber,
				@studentDiscount,
				@limit,
				@basePrice
			)
		end

		declare @conferenceID int
		set @conferenceID = @@identity
		declare @d date = @startDate

		while @d <= @endDate
			begin
				exec procedure_addConferenceDay
						@conferenceID,
						@d

				set @d = dateadd(d, 1, @d)
			end
        commit tran add_conference
	end try
	begin catch
        rollback tran add_conference
		declare @errorMsg nvarchar(2048)
			= 'Cannot add conference. Error message: '
			+ error_message();
		;throw 52000, @errorMsg, 1
	end catch

end
go


create procedure procedure_addPriceThreshold
	@conferenceID int,
	@startDate date,
	@endDate date,
	@discount real
as
begin
	set nocount on
	begin try
		if (@conferenceID is null or
			@startDate is null or
			@endDate is null or
			@discount is null
		)
			begin
				;throw 52000, 'All arguments are compulsory.', 1
			end

		if(@discount <= 0 or @discount >= 1)
			begin
				;throw 52000, 'Discount cannot be bigger than 1 and smaller than 0', 1
			end

		if(@startDate > @endDate)
			begin
				;throw 52000, 'Start date has to bo earlier than end date', 1
			end

		if(@startDate < getdate())
			begin
				;throw 52000, 'Start date is earlier than today', 1
			end

		if not exists (
			select *
			from Conferences
			where conferenceID = @conferenceID
		)
			begin
				;throw 52000, 'Conference does not exist', 1
			end

		if(@endDate > (
				select StartDate
				from Conferences
				where ConferenceID = @conferenceID
			)
		)
			begin
				;throw 52000, 'End date has to be earlier than conference start date', 1
			end

		if(0 < ( 
				select count(PriceID)
				from Prices
				where ConferenceID = @conferenceID and (
					(StartDate <= @endDate and @endDate <= EndDate)
					or (StartDate <= @startDate and @startDate <= EndDate)
				)
			)
		)
			begin
				;throw 52000, 'Conference has price threshold during this time', 1;
			end

		insert into Prices (
			ConferenceID,
			StartDate,
			EndDate,
			Discount
		)
		values (
			@conferenceID,
			@startDate,
			@endDate,
			@discount
		)
	end try

	begin catch 
		declare @errorMsg nvarchar(2048)
			= 'Cannot add price threshold. Error message: '
			+ error_message();
		;throw 52000, @errorMsg, 1
	end catch
end 
go


create procedure procedure_deletePriceThreshold
	@priceID int
as
begin
	set nocount on
	begin try
		if(@priceID is null)
			begin
				;throw 52000, 'All arguments are compulsory', 1
			end

		if not exists (
			select * 
			from Prices
			where PriceID = @priceID
		)
			begin
				;throw 52000, 'Price threshold does not exist', 1
			end

		delete Prices	
			where PriceID = @priceID
	end try

	begin catch 
		declare @errorMsg nvarchar(2048)
			= 'Cannot delete price treshold. Error message: '
			+ error_message();
		;throw 52000, @errorMsg, 1
	end catch

end
go


create procedure procedure_addIndividualClient
	@firstName varchar(50),
	@lastName varchar(50),
	@phone varchar(9),
	@email varchar(50),
	@studentCardID varchar(50),
	@countryName varchar(50),
	@cityName varchar(50),
	@street varchar(50),
	@buildingNumber varchar(10)

as
begin
    begin tran addIndividualClient
	set nocount on
	begin try
		if (@phone is null or
			@street is null or
			@buildingNumber is null or
			@cityName is null or
			@countryName is null or
			@email is null or
			@firstName is null or
			@lastName is null
		)
			begin
				;throw 52000, 'All arguments (beside StudentCardID) are compulsory ', 1
			end

		if not exists (
			select * 
			from city
			where city = @cityName and
				CountryID = (
					select CountryID
					from Country
					where Country = @countryName
				)
		)
			begin
				exec procedure_addCity
						@cityName,
						@countryName
			end

			insert into Clients (
			Phone,
			Street,
			BuildingNumber,
			CityID,
			Email
		)
		values (
			@phone,
			@street,
			@buildingNumber,
			(
				select CityID 
				from City
				where City = @cityName and
				CountryID = (
					select CountryID
					from Country
					where Country = @countryName	
				)
			),
			@email
		)

		declare @clientID int
		set @clientID = @@identity

		insert into Person default values
		declare @personID int
		set @personID = @@identity


		insert into IndividualClient (
			ClientID,
			PersonID,
			FirstName,
			LastName
		)
		values (
			@clientID,
			@personID,
			@firstName,
			@lastName
		)

		if(@studentCardID is not null)
			begin
				insert into Student (
					StudentCardID,
					PersonID
				)
				values (
					@studentCardID,
					@personID
				)
			end
	commit tran addIndividualClient
	end try
	begin catch
	    rollback tran addIndividualClient
		declare @errorMsg nvarchar(2048)
			= 'Cannot add individual client. Error message: '
			+ error_message();
		;throw 52000, @errorMsg, 1
	end catch
end
go


create procedure procedure_addCompany
	@CompanyName varchar(50),
	@Nip varchar(50),
	@Phone varchar(9),
	@Email varchar(50),

	@Country varchar(50),
	@CityName varchar(50),
	@Street varchar(50),
	@BuildingNumber varchar(10)
as
begin
	set nocount on
	begin try
	begin tran
		if (
			@Phone is null or 
			@Street is null or
			@CityName is null or
			@BuildingNumber is null or
			@Email is null or
			@Nip is null or
			@CompanyName is null
		)
			begin
				;throw 52000, 'All arguments are compulsory', 1
			end

		if not exists (
			select * 
			from City
			where City = @CityName  and
				CountryID = (
					select CountryID
					from Country
					where Country = @Country	
				)
		)
			begin
				exec procedure_addCity @CityName, @Country
			end

		insert into Clients (
			Phone,
			Street,
			BuildingNumber,
			CityID,
			Email
		)
		values (
			@Phone,
			@Street,
			@BuildingNumber,
			(
				select CityID
				from City
				where city = @cityName and
				CountryID = (
					select CountryID
					from Country
					where Country = @Country	
				)
			),
			@Email
		)

		declare @ClientID int
		set @ClientID = @@identity

		insert into Company (
			ClientID,
			CompanyName,
			NIP
		)
		values(
			@ClientID,
			@CompanyName,
			@Nip
		)
	commit work
	end try
	begin catch
	    rollback work
		declare @errorMessage nvarchar(2048)
			= 'Cannot add CompanyClient. Error message: '
			+ error_message();
		;throw 52000, @errorMessage, 1
	end catch
end
go


create procedure procedure_addIndividualReservation
	@ClientID int,
	@ConferenceID int,
	@DayList IndividualReservation READONLY
as
begin
set nocount on
	begin try
	    begin tran addIndividualReservation
		if (
			@ClientID is null or
			@ConferenceID is null
		)
		begin
			;throw 52000, 'All arguments are compulsory', 1
		end
		--sprawdzam czy client istnieje
		if not exists(select * from Clients where ClientID = @ClientID)
		begin
            ;throw 52000, 'Client does not exists', 1
        end
		--sprawdzam czy client jest ind
		if not exists(select * from Clients as c inner join IndividualClient IC on c.ClientID = IC.ClientID where c.ClientID = @ClientID)
		begin
            ;throw 52000, 'Client is not individual', 1
        end
        --sprawdzam czy konferncja istnieje
		if not exists(select * from Conferences where ConferenceID = @ConferenceID)
		begin
            ;throw 52000, 'Conference does not exists', 1
        end

		insert into Reservation(
			ClientID,
			ReservationDate
		)
		values(
			@ClientID,
			GETDATE()
		)
		declare @ReservationID int = @@IDENTITY;

		declare @max int = (select count(*) from @DayList);
		if (@max <= 0)
		begin
            ;throw 52000, 'DayList cannot be empty', 1
        end
		declare @iterator int = 1;
		declare @day date;

		while (@iterator <= @max)
		begin
		    set @day = (select ConferenceDate from @DayList where ID = @iterator)
		    declare @ConferenceDayID int = dbo.function_returnConferenceDay (@ConferenceID, @day);
		    if (@ConferenceDayID is null)
		    begin
                ;throw 52000, 'Conference day does not exists', 1
            end
            exec procedure_addIndividualDayReservation @ReservationID, @ConferenceDayID;
		    set @iterator = @iterator + 1;
        end

	    commit tran addIndividualReservation
	end try
	begin catch
	    rollback tran addIndividualReservation
		declare @errorMessage nvarchar(2048)
			= 'Cannot add Reservation. Error message: '
			+ error_message();
		;throw 52000, @errorMessage, 1
	end catch
end
go


create procedure procedure_addDayParticipant
	@PersonID int,
	@DayReservationID int
as
begin
	set nocount on
	begin try
	if (
		@PersonID is null or
		@DayReservationID is null
	)
	begin
		;throw 52000, 'All arguments are compulsory', 1
	end
	if not exists(select * from Person where PersonID = @PersonID)
	begin
        ;throw 52000, 'Person does not exists', 1
    end
	if not exists(select * from DayReservation where DayReservationID = @DayReservationID)
	begin
        ;throw 52000, 'DayReservationID does not exist', 1
    end


	insert into DayParticipant(
		PersonID,
		DayReservationID
	)
	VALUES(
		@PersonID,
		@DayReservationID
	)
	end try 
	begin catch
		declare @errorMessage nvarchar(2048)
			= 'Cannot add DayParticipant. Error message: '
			+ error_message();
		;throw 52000, @errorMessage, 1
	end catch
end
go


create procedure procedure_addIndividualDayReservation
	@ReservationID int,
	@ConferenceDayID int
as
begin
	set nocount on
	begin try
		if (
			@ConferenceDayID is null
			or @ReservationID is null
		)
		begin
			;throw 52000, 'All arguments are compulsory', 1
		end


		if exists(
			select * from DayReservation
			where ReservationID = @ReservationID and ConferenceDayID = @ConferenceDayID
		)
		begin 
			;throw 52000, 'User has already booked this day of conference', 1
		end

		declare @reservationPersonID int;
		set @reservationPersonID = dbo.function_returnPersonID(@ReservationID);

		--sprawdza czy klient jest studentem jak jest to daje mu bilet ulgowy
		declare @StudentTickets int;
		declare @NormalTickets int;
		if exists (
			select * from Person
			inner join Student on Student.PersonID = Person.PersonID
			where @reservationPersonID = Person.PersonID
		)
		begin
			set @StudentTickets = 1;
			set @NormalTickets = 0;
		end
		else
		begin
			set @StudentTickets = 0;
			set @NormalTickets = 1;
		end


		insert into DayReservation(
			ConferenceDayID,
			ReservationID,
			NormalTickets,
			StudentTickets
		)
		values(
			@ConferenceDayID,
			@ReservationID,
			@NormalTickets,
			@StudentTickets
		)

	exec procedure_addDayParticipant @reservationPersonID, @@IDENTITY
	end try
	begin catch
		declare @errorMessage nvarchar(2048)
			= 'Cannot add DayReservation. Error message: '
			+ error_message();
		;throw 52000, @errorMessage, 1
	end catch
end
go

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
            ;throw 52000, 'Podaj wszystkie parametry', 1
        end

        --sprawdzam czy client istnieje
		if not exists(select * from Clients where ClientID = @ClientID)
		begin
            ;throw 52000, 'Client does not exists', 1
        end
		--sprawdzam czy client jest comp
		if not exists(select * from Clients as c inner join Company C2 on c.ClientID = C2.ClientID where c.ClientID = @ClientID)
		begin
            ;throw 52000, 'Client is not Company', 1
        end
        --sprawdzam czy konferncja istnieje
		if not exists(select * from Conferences where ConferenceID = @ConferenceID)
		begin
            ;throw 52000, 'Conference does not exists', 1
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

        declare @iterator1 int =  1;
        declare @iterator2 int;

        declare @date date;
        declare @normalTickets int;
        declare @conferenceDayID int;
        declare @StudentTickets int;
        declare @dayReservationID int;

        declare @numberOfStudents int = (select count(*) from @StudentList);
        declare @studentIDCard varchar(50);
        declare @studentDate date;

        while (@iterator1 <= @numberOfDays)
        begin
            set @date = (select ConferenceDate from @DayList where ID = @iterator1);
            set @conferenceDayID = dbo.function_returnConferenceDay (@ConferenceID, @date)
            if (@conferenceDayID is null)
            begin
                ;throw 52000, 'Conference day does not exist', 1
            end
            set @normalTickets = (select NormalTickets from @DayList where ID = @iterator1);
            set @studentTickets = (select count(*) from @StudentList where ConferenceDate = @date);
            exec procedure_addCompanyDayReservation @ReservationID, @ConferenceID, @normalTickets, @StudentTickets
            set @dayReservationID = @@IDENTITY;
            set @iterator2 = 1;
            while (@iterator2 <= @numberOfStudents)
            begin
                set @studentDate = (select ConferenceDate from @StudentList where ID = @iterator2);
                if not exists (select * from @DayList where ConferenceDate = @studentDate)
                begin
                    ;throw 52000, 'invalid student date', 1
                end
                set @studentIDCard = null;
                set @studentIDCard = (select StudentIDCard from @StudentList where ConferenceDate = @date and ID = @iterator2);
                if (@studentIDCard is not null and isnumeric(@studentIDCard) = 1)
                begin
                    exec procedure_initializeEmployee @dayReservationID, @studentIDCard;
                end
                set @iterator2 = @iterator2 + 1;
            end


            set @iterator2 = 1;
            while (@iterator2 <= @normalTickets)
            begin
                exec procedure_initializeEmployee @dayReservationID, null
                set @iterator2 = @iterator2 + 1;
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


create procedure procedure_addCompanyDayReservation
	@ReservationID int,
    @ConferenceDayID int,
	@NormalTickets int,
	@StudentTickets int
as
begin
	set nocount on
	begin try
		if (
			@ReservationID is null or
			@ConferenceDayID is null or
			@NormalTickets is null or 
			@StudentTickets is null
		)
		begin
			;throw 52000, 'Podaj wszystkie parametry', 1
		end

		if (@ConferenceDayID is null)
		begin 
			;throw 52000, 'Conference does not exist', 1
		end

		insert into DayReservation(
			ConferenceDayID,
			ReservationID,
			NormalTickets,
			StudentTickets
		)
		values(
			@ConferenceDayID,
			@ReservationID,
			@NormalTickets,
			@StudentTickets
		)
	end try 
	begin catch
		declare @errorMessage nvarchar(2048)
			= 'Cannot add DayReservation. Error message: '+ error_message();
		;throw 52000, @errorMessage, 1
	end catch
end
go

create procedure procedure_initializeEmployee
	@DayReservationID int,
	@StudentIDCard varchar(50)
as
begin
	set nocount on
	begin try
		if (
			@DayReservationID is null
		)
		begin
			;throw 52000, 'Podaj wszystkie parametry', 1
		end

		declare @ReservationID int = (select ReservationID from DayReservation where DayReservationID = @DayReservationID);
		declare @ClientID int;
		set @ClientID = (select ClientID from Reservation where ReservationID = @ReservationID)

		if not exists (select * from Company where ClientID = @ClientID)
		begin 
			;throw 52000, 'Reservation is not made by company', 1
		end

		insert into Person default values
		declare @PersonID int = @@IDENTITY;
		insert into Employee(
			ClientID,
			PersonID,
			FirstName,
			LastName
		)
		VALUES(
			@ClientID,
			@PersonID,
			null,
			null
		)
		if (@StudentIDCard is not null)
		begin 
			insert into Student(
				StudentCardID,
				PersonID
			)
			values(
				@StudentIDCard,
				@PersonID
			)
		end
		

		exec procedure_addDayParticipant @PersonID, @DayReservationID
	end try 
	begin catch
		declare @errorMessage nvarchar(2048)
			= 'Cannot InitializeEmployee. Error message: '
			+ error_message();
		;throw 52000, @errorMessage, 1
	end catch
end
go



create procedure procedure_addEmployee
	@personID int,
	@firstName varchar(50),
	@lastName varchar(50)	
as
begin
	set nocount on
	begin try
		
		if (@personID is null or
			@firstName is null or
			@lastName is null
		)
			begin
				;throw 52000, 'Podaj wszystkie dane', 1
			end
	
		if not exists (
			select * 
			from Employee
			where PersonID = @personID
		)
			begin
				;throw 52000, 'Osoba o tym ID nie istnieje', 1
			end

		update Employee
		set FirstName = @firstName, LastName = @lastName
		where PersonID = @personID


	end try
	begin catch 
		declare @errorMessage nvarchar(2048)
			= 'Cannot add employee. Error message: '
			+ error_message();
		;throw 52000, @errorMessage, 1
	end catch
end
go


create procedure procedure_addWorkshopIndividualReservation
    @WorkshopID int,
    @ClientID int
as
begin
    set nocount on
    begin try
        begin tran addWorkshopIndividualReservation

        if (@WorkshopID is null or @ClientID is null)
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

        declare @ConferenceDayID int = (select ConferenceDayID from Workshop where WorkshopID = @WorkshopID)
        declare @DayReservationID int = (select DayReservationID from DayReservation DR
            inner join Reservation AS R on R.ReservationID = DR.ReservationID
            where DR.ConferenceDayID = @ConferenceDayID and R.ClientID = @ClientID)

        if not exists (select DayReservationID from DayReservation DR
            inner join Reservation AS R on R.ReservationID = DR.ReservationID
            where DR.ConferenceDayID = @ConferenceDayID and R.ClientID = @ClientID)
        begin
            ;throw 52000, 'User has to book Conference to book a workshop', 1
        end

        if not exists (select * from IndividualClient where ClientID = @ClientID)
        begin
            ;throw 52000, 'Invalid ClientID - client is not individual', 1
        end

        declare @PersonID int = (select PersonID from IndividualClient where ClientID = @ClientID)
        declare @DayParticipantID int = (select DayParticipantID from DayParticipant
            inner join Person P on DayParticipant.PersonID = P.PersonID where P.PersonID = @PersonID)

        insert into WorkshopReservation(
            WorkshopID, DayReservationID, Tickets
        )VALUES (
            @WorkshopID, @DayReservationID, 1
        )
        declare @WorkshopReservationID int = @@identity;
        insert into WorkshopParticipant (
            DayParticipantID, WorkshopReservationID
        )VALUES(
            @DayParticipantID, @WorkshopReservationID
        )
    commit tran addWorkshopIndividualReservation
    end try
    begin catch
        rollback tran addWorkshopIndividualReservation
        declare @errorMessage nvarchar(2048)
            = 'Cannot add WorkshopReservation. Error message: '
            + error_message();
        ;throw 52000, @errorMessage, 1
    end catch
end

create procedure procedure_addWorkshopCompanyReservation
    @ClientID int,
    @WorkshopID int,
    @PersonIDList WorkshopReservation READONLY
as
begin
    set nocount on
    begin try
    begin tran addWorkshopCompanyReservation
        if (@WorkshopID is null or @ClientID is null)
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
        declare @DayReservationID int = (select DayReservationID from DayReservation DR
            inner join Reservation AS R on R.ReservationID = DR.ReservationID
            where DR.ConferenceDayID = @ConferenceDayID and R.ClientID = @ClientID)

        if not exists (select DayReservationID from DayReservation DR
            inner join Reservation AS R on R.ReservationID = DR.ReservationID
            where DR.ConferenceDayID = @ConferenceDayID and R.ClientID = @ClientID)
        begin
            ;throw 52000, 'User has to book Conference to book a workshop', 1
        end

        declare @TicketsNumber int = (select count(*) from @PersonIDList)

        insert into WorkshopReservation(
            WorkshopID, DayReservationID, Tickets
        )  VALUES (
            @WorkshopID, @DayReservationID, @TicketsNumber
        )
        declare @WorkshopReservation int = @@identity;
        declare @PersonID int;
        declare @DayParticipantID int;
        declare @iterator int = 1;
        while (@iterator <= @TicketsNumber)
        begin
            set @PersonID = (select * from @PersonIDList where ID = @iterator)
            if not exists(
                select * from DayParticipant where PersonID = @PersonID and DayReservationID = @DayReservationID
            )
            begin
                ;throw 52000, 'Person is not a participant of Conference in this day', 1
            end
            set @DayParticipantID = (select DayParticipantID from DayParticipant where PersonID = @PersonID and DayReservationID = @DayReservationID)
            insert into WorkshopParticipant(
                DayParticipantID, WorkshopReservationID
            ) VALUES (
                @DayParticipantID, @WorkshopReservation
            )
            set @iterator = @iterator + 1
        end
    commit tran addWorkshopCompanyReservation
    end try
    begin catch
        rollback tran addWorkshopCompanyReservation
        declare @errorMessage nvarchar(2048)
            = 'Cannot add Payment. Error message: '
            + error_message();
        ;throw 52000, @errorMessage, 1
    end catch
end


create procedure procedure_addPayment
	@ReservationID int
as
begin
	set nocount on
	begin try
		if (
			@ReservationID is null
		)
		begin
			;throw 52000, 'Podaj wszystkie parametry', 1
		end
	
		if not exists (
			select * from Reservation where ReservationID = @ReservationID
		)
		begin
			;throw 52000, 'Reservation does not exist', 1
		end

		if exists (
			select * from Reservation 
			where ReservationID = @ReservationID 
				and PaymentDate is not null
		)
		begin
			;throw 52000, 'Reservation has already been paid', 1
		end

		update Reservation 
		set PaymentDate = GETDATE()
		where ReservationID = @ReservationID
	
	end try
	begin catch 
		declare @errorMessage nvarchar(2048)
			= 'Cannot add Payment. Error message: '
			+ error_message();
		;throw 52000, @errorMessage, 1
	end catch
end
go

create procedure procedure_removeReservation
    @ReservationID int
as
begin
    begin try
    begin tran removeReservation
    if not exists(
        select * from Reservation
        where ReservationID = @ReservationID
    )
    begin
        ;throw 52000, 'Reservation does not exist', 1
    end
    delete from Reservation where
        ReservationID = @ReservationID
    commit tran removeReservation
    end try
    begin catch
        rollback tran removeReservation
        declare @errorMessage nvarchar(2048)
			= 'Cannot delete reservation. Error message: '
			+ error_message();
	    ;throw 52000, @errorMessage, 1
    end catch
end
	


