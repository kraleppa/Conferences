
/*
    @List = '2021-07-20;2021-07-21;2021-07-22'
 */


CREATE FUNCTION [dbo].Split1(@input AS Varchar(4000), @char varchar(1) )

RETURNS
      @Result TABLE(Value date)
AS
BEGIN
      DECLARE @str VARCHAR(20)
      DECLARE @ind Int
      IF(@input is not null)
      BEGIN
            SET @ind = CharIndex(@char,@input)
            WHILE @ind > 0
            BEGIN
                  SET @str = SUBSTRING(@input,1,@ind-1)
                  SET @input = SUBSTRING(@input,@ind+1,LEN(@input)-@ind)
                  INSERT INTO @Result values (@str)
                  SET @ind = CharIndex(@char,@input)
            END
            SET @str = @input
            INSERT INTO @Result values (@str)
      END
      RETURN
END

CREATE FUNCTION [dbo].Split2(@input AS Varchar(4000), @char varchar(1) )

RETURNS
      @Result TABLE(Value varchar(4000))
AS
BEGIN
      DECLARE @str VARCHAR(3000)
      DECLARE @ind Int
      IF(@input is not null)
      BEGIN
            SET @ind = CharIndex(@char,@input)
            WHILE @ind > 0
            BEGIN
                  SET @str = SUBSTRING(@input,1,@ind-1)
                  SET @input = SUBSTRING(@input,@ind+1,LEN(@input)-@ind)
                  INSERT INTO @Result values (@str)
                  SET @ind = CharIndex(@char,@input)
            END
            SET @str = @input
            INSERT INTO @Result values (@str)
      END
      RETURN
END

    create procedure procedure_individualReservation
    @ClientID int,
    @ConferenceID int,
    @List varchar(3000)
as
    begin
        set nocount on
        begin try
            declare @insertTable IndividualReservation
            insert into @insertTable (ConferenceDate)
            select VALUE from Split1 (@List, ',')

            exec procedure_addIndividualReservation @ClientID,
                @ConferenceID, @insertTable
        end try
        begin catch
            declare @errorMessage nvarchar(2048)
			= 'Cannot add InividualReservation. Error message: '
			+ error_message();
		;throw 52000, @errorMessage, 1
        end catch
    end

/*
    '2022-07-20,30,305376,305377,305378,305379;2022-07-21,20,305376,305377,305378,305379'
 */

create procedure procedure_companyReservation
    @ClientID int,
    @ConferenceID int,
    @List varchar(3000)
as
    begin
        set nocount on
        begin try


            declare @DayList CompanyReservation;
            declare @StudentList StudentIDCards;

            declare @inTable table(ID int identity (1,1), Val varchar(3000));
            declare @dayTable table(ID int identity (1,1), Val varchar(3000))
            insert into @inTable(Val)
            select VALUE from Split2 (@List, ';')




            declare @iterator int = 1;
            declare @dayNumber int = (select count(*) from @inTable)
            declare @string varchar(3000);
            declare @length int;
            declare @iterator2 int = 1;
            declare @Day date;
            declare @StudentIdCard varchar(50);
            declare @normalTickets int;
            while (@iterator <= @dayNumber)
            begin
                set @string = (select Val from @inTable where ID = @iterator)
                delete from @dayTable where id <> 0
                insert into @dayTable
                select value from Split2 (@string, ',')

                set @length = (select max(ID) from @dayTable)

                set @iterator2 = (select min(ID) from @dayTable);
                set @day = (select val from @dayTable where ID = @iterator2)
                set @normalTickets = (select val from @dayTable where ID = @iterator2 + 1)
                set @iterator2 = @iterator2 + 2;
                insert into @DayList (ConferenceDate, NormalTickets)VALUES(@Day, @normalTickets)
                while (@iterator2 <= @length)
                begin
                    set @StudentIdCard = (select Val from @dayTable where ID = @iterator2)
                    insert into @StudentList(ConferenceDate, StudentIDCard)VALUES(@Day, @StudentIDCard)
                    set @iterator2 = @iterator2 + 1;
                end
                set @iterator = @iterator + 1;
            end

            exec procedure_addCompanyReservation @ClientID, @ConferenceID, @DayList, @StudentList

        end try
        begin catch
            declare @errorMessage nvarchar(2048)
			= 'Cannot add CompanyReservation. Error message: '
			+ error_message();
		;throw 52000, @errorMessage, 1
        end catch
    end


