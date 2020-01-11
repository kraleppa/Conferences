--Procedures

create procedure procedure_addWorkshopToDictionary
	@WorkshopName varchar(50),
	@WorkshopDescription varchar(255),
	@Price money
as
begin
	set nocount on
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
	Declare @ConferenceDayID int = dbo.function_returnConferenceDay(@ConferenceID, @Date);
	begin try
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
			;throw 52000, 'Start time cannot be bigger than End time', 1
		end

		Declare @Price money = dbo.function_returnValueOfWorkshop(@WorkshopDictionaryID);

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
				;throw 52000,  'Podaj nazwe miasta i kraju', 1
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
				;throw 52000,  'Podaj wszystkie parametry.', 1
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
				;throw 52000,  'Podaj wszystkie parametry.', 1
			end

		if (@startDate <= getdate())
			begin
				;throw 52000, 'Data rozpoczêcia musi byæ pózniejsza ni¿ 
							   dzisiejsza', 1
			end

		if (@startDate >@endDate)
			begin
				;throw 52000, 'Data rozpoczêcia musi byæ pó¿niejsza ni¿
							   data zakoñczenia', 1
			end

		if(@studentDiscount < 0 or @studentDiscount > 1)
			begin
				;throw 52000, 'Zni¿ka musi byæ z przedzia³u [0,1]', 1
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
	end try

	begin catch 
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
				;throw 52000, 'Podaj wszystkie parametry', 1
			end

		if(@discount <= 0 or @discount >= 1)
			begin
				;throw 52000, 'Zni¿ka musi byæ z przedzia³u (0,1)', 1
			end

		if(@startDate > @endDate)
			begin
				;throw 52000, 'Data rozpoczêcia musi byæ 
							   pózniejsza ni¿ data zakoñczenia', 1
			end

		if(@startDate < getdate())
			begin
				;throw 52000, 'Nie mo¿esz ustaliæ progu w przesz³oœci', 1
			end

		if not exists (
			select *
			from Conferences
			where conferenceID = @conferenceID
		)
			begin
				;throw 52000, 'Nie ma takiej konferencji', 1
			end

		if(@endDate > (
				select StartDate
				from Conferences
				where ConferenceID = @conferenceID
			)
		)
			begin
				;throw 52000, 'Daty progu musz¹ byæ przed 
							   dat¹ konferencji', 1
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
				;throw 52000, 'Konferencja ma ju¿ próg cenowy 
					zawieraj¹cy czêœæ tego okresu', 1;
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
			= 'Cannot add price treshold. Error message: '
			+ error_message();
		;throw 52000, @errorMsg, 1
	end catch
end 
go


create procedure procedure_deletePriceTreshold
	@priceID int
as
begin
	set nocount on
	begin try
		if(@priceID is null)
			begin
				;throw 52000, 'Podaj ID progu cenowego', 1
			end

		if not exists (
			select * 
			from Prices
			where PriceID = @priceID
		)
			begin
				;throw 52000, 'Podany próg cenowy nie istnieje.', 1
			end

		delete Prices	
			where PriceID = @priceID
	end try

	begin catch 
		declare @errorMsg nvarchar(2048)
			= 'Cannot elete price treshold. Error message: '
			+ error_message();
		;throw 52000, @errorMsg, 1
	end catch

end
go


create procedure procedure_addIndividualClient
	@phone varchar(9),
	@street varchar(50),
	@buildingNumber varchar(10),
	@cityName varchar(50),
	@countryName varchar(50),
	@email varchar(50),
	@firstName varchar(50),
	@lastName varchar(50),
	@studnetCardID varchar(50)
as
begin
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
				;throw 52000, 'Podaj wszystkie dane 
							   (nr legitymacji jest opcjonalny).', 1
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

		if exists (
			select * 
			from Clients
			where Email = @email
		)
			begin
				;throw 52000, 'Adres email jest ju¿ wykorzystany', 1
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

		if(@studnetCardID is not null)
			begin
				if exists (
					select * 
					from Student
					where StudentCardID = @studnetCardID
				)
					begin
						;throw 52000, 'Ten numer legitymacji istnieje ju¿ w bazie', 1
					end

				insert into Student (
					StudentCardID,
					PersonID
				)
				values (
					@studnetCardID,
					@personID
				)
			end
	end try

	begin catch 
		declare @errorMsg nvarchar(2048)
			= 'Cannot add individual client. Error message: '
			+ error_message();
		;throw 52000, @errorMsg, 1
	end catch
end
go


create procedure procedure_addCompany
	@Phone varchar(9),
	@Street varchar(50),
	@CityName varchar(50),
	@Country varchar(50),
	@BuildingNumber varchar(10),
	@Email varchar(50),
	@Nip varchar(50),
	@CompanyName varchar(50)
as
begin
	set nocount on
	begin try 
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
				;throw 52000, 'Podaj wszystkie parametry', 1
			end
		if exists(
			select * from Clients
			where Email like @Email
		)
			begin
				;throw 52000, 'Adres email jest juz wykorzystany',1 
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
	end try
	begin catch 
		declare @errorMessage nvarchar(2048)
			= 'Cannot add CompanyClient. Error message: '
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
