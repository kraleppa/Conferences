--840 workshopow
--100 w slowniku

declare @iterator int = 1
while (@iterator <= 840)
begin
    DECLARE @time1 Time = '07:00:00'
    DECLARE @time2 TIME = '22:00:00'
    declare @startTime time = '09:00:00';
    declare @endTime time = '08:00:00';
    DECLARE @maxSeconds int
    DECLARE @randomSeconds int
    while (@startTime > @endTime)
    begin
        set @maxSeconds= DATEDIFF(ss, @time1, @time2)
        set @randomSeconds = (@maxSeconds + 1)
        * RAND(convert(varbinary, newId() ))
        set @startTime =  (SELECT (convert(Time, DateAdd(second, @randomSeconds, @time1)))
        AS RandomTime)

        set @randomSeconds = (@maxSeconds + 1)
        * RAND(convert(varbinary, newId() ))
        set @EndTime =  (SELECT (convert(Time, DateAdd(second, @randomSeconds, @time1)))
        AS RandomTime)
    end

    declare @ConferenceDayMaxID int = (select max(ConferenceDayID) from ConferenceDay)

    declare @ConferenceDayID int =  ABS(CHECKSUM(NewId())) % @ConferenceDayMaxID + 1

    declare @WorkshopDictionaryID int = ABS(CHECKSUM(NewId())) % 100 + 1

    declare @Price money = (select Price from WorkshopDictionary where WorkshopDictionaryID = @WorkshopDictionaryID)
    declare @LimitConf int = (select Limit from Conferences C inner join ConferenceDay CD on C.ConferenceID = CD.ConferenceID
    where ConferenceDayID = @ConferenceDayID)
    declare @Limit int = @LimitConf - ABS(CHECKSUM(NewId())) % @LimitConf
    insert into Workshop(WorkshopDictionaryID, ConferenceDayID, StartTime, EndTime, Limit, Cancelled, Price)
    VALUES (@WorkshopDictionaryID, @ConferenceDayID, @startTime, @endTime, @Limit, 0, @Price)
    set @iterator = @iterator + 1
end
