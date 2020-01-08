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
	@ConferenceDayID int,
	@StartTime time,
	@EndTime time,
	@Limit int
as
begin
	set nocount on
	begin try
		if not exists (
			select * from ConferenceDay
			where ConferenceDayID = @ConferenceDayID
		)
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
		Declare @Price money = 0;-- function get price of workshop in dictionary by id

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
		declare @errorMesasage nvarchar(2048) = 
		'Cannot add workshop. Error message: ' + ERROR_MESSAGE();
		;throw 52000, @errorMsg, 1;
	end catch
end
go
