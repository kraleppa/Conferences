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

create type [dbo].[NamesTable] as table (
    IDOsoby int identity (1,1),
    Imie varchar(50),
    Nazwisko  varchar(50),
    Legitymacja varchar(50)
)

create type [dbo].[ConferenceTable] as table (
    ID int identity (1,1),
    IDOsoby int,
    Data date
)

create type [dbo].[WorkshopTable] as table (
    ID int identity (1,1),
    IDOsoby int,
    WorkshopID int
)