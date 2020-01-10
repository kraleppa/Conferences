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


--create procedure procedure_addWorkshop
--	@WorkshopDictionaryID int,
--	@ConferenceDayID int,
--	@StartTime time,--
--	@EndTime time,
--	@Limit int
--as
--begin
--	set nocount on
--	begin try
--		if not exists (
--			select * from ConferenceDay
--			where ConferenceDayID = @ConferenceDayID
--		)
--		begin
--			;throw 52000, 'Conference day does not exist', 1
--		end
		
--		if not exists (
--			select * from WorkshopDictionary
--			where WorkshopDictionaryID = @WorkshopDictionaryID
--		)
--		begin 
--			;throw 52000, 'Workshop does not exist in dictionary',1
--		end
--		if (@StartTime > @EndTime)
--		begin 
--			;throw 52000, 'Start time cannot be bigger than End time', 1
--		end
--		Declare @Price money = 0;-- function get price of workshop in dictionary by id

--		insert into Workshop (
--		WorkshopDictionaryID,
--		ConferenceDayID,
--		StartTime,
--		EndTime,
--		Limit,
--		Price
--		)
--		VALUES (
--			@WorkshopDictionaryID,
--			@ConferenceDayID,
--			@StartTime,
--			@EndTime,
--			@Limit,
--			@Price
--		)
--	end try
--	begin catch
--		declare @errorMesasage nvarchar(2048) = 
--		'Cannot add workshop. Error message: ' + ERROR_MESSAGE();
--		;throw 52000, @errorMsg, 1;
--	end catch
--end
--go


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

		if not exists (
			select * 
			from City
			where City = @cityName
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
				 where city = @cityName
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



