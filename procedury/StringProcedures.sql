
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
go


/* firstname1,lastname2,IDCard;ConfDay1,ConfDat2;WorkshopID1,WorkshopID2|firstname1,lastname2,null;ConfDay1;WorkshopID1*/
create procedure procedure_EmployeeInformation
    @ClientID int,
    @ReservationID int,
    @List varchar(4000)
as
    begin
        set nocount on
        begin try
            declare @PeopleTable table (ID int identity (1,1), Details varchar(4000))
            insert into @PeopleTable (Details)
            select * from Split2 (@List, '|')


            declare @PersonOut NamesTable;
            declare @ConfOut ConferenceTable;
            declare @WorkshopOut WorkshopTable;

            declare @PersonDetails table(ID int identity(1,1), Details varchar(4000))
            declare @PersonInfromations table(IDOsoby int identity (1,1), Details varchar(4000))
            declare @PersonConfDays table (ID int identity (1,1), Details varchar(4000))
            declare @PersonWorkshops table (ID int identity (1,1), Details varchar(4000))
            declare @IDCard varchar(50);
            declare @iterator1 int = 1;
            declare @iterator2 int;
            declare @idOsoby int;
            while (@iterator1 <= (select max(id) from @PeopleTable))
            begin
                delete from @PersonDetails where ID <> 0
                insert into @PersonDetails
                select * from Split2((select Details from @PeopleTable where @iterator1 = ID), ';')

                delete from @PersonInfromations where IDOsoby <> 0
                insert into @PersonInfromations
                select * from Split2((select Details from @PersonDetails where ID = (select min(id) from @PersonDetails)), ',')
                set @IDCard = (select Details from @PersonInfromations where IDOsoby = (select min(IDOsoby) from @PersonInfromations) + 2)
                if (@IDCard like 'null')
                    set @IDCard = null
                insert into @PersonOut (Imie, Nazwisko, Legitymacja)VALUES
                ((select Details from @PersonInfromations where IDOsoby = (select min(IDOsoby) from @PersonInfromations)),
                (select Details from @PersonInfromations where IDOsoby = (select min(IDOsoby) from @PersonInfromations) + 1),
                 @IDCard)
                set @idOsoby = @@IDENTITY;

                delete from @PersonConfDays where ID <> 0
                insert into @PersonConfDays (Details)
                select * from Split2 ((select Details from @PersonDetails where ID = (select min(id) from @PersonDetails) + 1), ',')

                set @iterator2 = (select min(ID) from @PersonConfDays)
                while (@iterator2 <= (select max(id) from @PersonConfDays))
                begin
                    insert into @ConfOut (IDOsoby, Data)
                    VALUES (@idOsoby, (select Details from @PersonConfDays where ID = @iterator2))
                    set @iterator2 = @iterator2 + 1;
                end

                delete from @PersonWorkshops where ID <> 0
                insert into @PersonWorkshops (Details)
                select * from Split2 ((select Details from @PersonDetails where ID = (select min(id) from @PersonDetails) + 2), ',')

                set @iterator2 = (select min(ID) from @PersonWorkshops)
                while (@iterator2 <= (select max(id) from @PersonWorkshops))
                begin
                    if ((select Details from @PersonWorkshops where ID = @iterator2) not like '')
                    begin
                        insert into @WorkshopOut (IDOsoby, WorkshopID)
                        VALUES (@idOsoby, (select Details from @PersonWorkshops where ID = @iterator2))

                    end
                    set @iterator2 = @iterator2 + 1;
                end
                set @iterator1 = @iterator1 + 1
            end

            exec procedure_addCompanyEmployeeInformation @ClientID, @ReservationID, @PersonOut, @ConfOut, @WorkshopOut
        end try
        begin catch
            declare @errorMessage nvarchar(2048)
			= 'Cannot add reservation details. Error message: '
			+ error_message();
		;throw 52000, @errorMessage, 1
        end catch
    end
go




