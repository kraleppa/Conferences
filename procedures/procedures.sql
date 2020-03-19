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
	    begin tran addWorkshop
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
		commit tran addWorkshop
	end try
	begin catch
	    rollback tran addWorkshop

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
	@discount real
as
begin
	set nocount on
	begin try
		if (@conferenceID is null or
			@startDate is null or
			@discount is null
		)
			begin
				;throw 52000, 'All arguments are compulsory.', 1
			end

		if(@discount <= 0 or @discount >= 1)
			begin
				;throw 52000, 'Discount cannot be bigger than 1 and smaller than 0', 1
			end

		if exists (
		    select *
		    from Prices
		    where StartDate > @startDate and
		          Discount > @discount
        )
		    begin
                ;throw 52000, 'Nie mozna dodac wyzszego progu niz pozniejszy', 1
            end

		if exists (
		    select *
		    from Prices
		    where StartDate < @startDate and
		          Discount < @discount
        )
		    begin
                ;throw 52000, 'Nie mozna dodac wyzszego progu niz wczesniej', 1
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

		if(@startDate > (
		    select StartDate
		    from Conferences
		    where ConferenceID = @conferenceID
        ))
			begin
				;throw 52000, 'Start date has to be earlier than conference start date', 1
			end

		if exists (
		    select *
		    from Prices
		    where StartDate = @startDate
        )
		    begin
                ;throw 52000, 'Prog o tej dacie juz istnieje', 1
            end

		insert into Prices (
			ConferenceID,
			StartDate,
			Discount
		)
		values (
			@conferenceID,
			@startDate,
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

				;throw 52000, 'Podany prog cenowy nie istnieje.', 1
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
		if not exists(
		    select * from Clients as c
		        inner join IndividualClient IC
		            on c.ClientID = IC.ClientID where c.ClientID = @ClientID
		    )
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
		    declare @ConferenceDayID int =
		        dbo.function_returnConferenceDay (@ConferenceID, @day);
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
            inner join Person P on DayParticipant.PersonID = P.PersonID where P.PersonID = @PersonID and @DayReservationID = DayParticipant.DayReservationID)

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
go



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


create procedure procedure_deleteReservation
    @ReservationID int
as
    begin
        set nocount on
        begin try
            begin tran deleteReservation
                delete from Reservation where ReservationID = @ReservationID
            commit tran deleteReservation
        end try
        begin catch
            rollback tran deleteReservation
            declare @errorMessage nvarchar(2048)
			= 'Cannot delete reservation. Error message: '
			+ error_message();
		;throw 52000, @errorMessage, 1
        end catch
    end
go

create procedure procedure_deleteUnpaidReservation
as
    begin
        set nocount on
        begin try
            begin tran deleteReservations
            delete from Reservation where ReservationID in
            (select view_reservationOnConferenceToDelete.ReservationID from view_reservationOnConferenceToDelete)
            commit tran deleteReservations
        end try
        begin catch
            rollback tran deleteReservations
            declare @errorMessage nvarchar(2048)
			= 'Cannot delete unpaid reservations. Error message: '
			+ error_message();
		;throw 52000, @errorMessage, 1
        end catch
    end


