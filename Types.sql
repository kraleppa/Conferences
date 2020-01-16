create type [dbo].[StudentIDCards] as table (
    ID int identity (1,1),
    ConferenceDate date,
    StudentIDCard varchar(50)
)

create type [dbo].[IndividualReservation] as table (
    ID int identity (1,1),
    ConferenceDate date
)

create type [dbo].[CompanyReservation] as table (
    ID int identity (1,1),
    ConferenceDate date,
    NormalTickets int
)

create type [dbo].[WorkshopReservation] as table (
    ID int identity (1,1),
    PersonID int
)