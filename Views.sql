--Views

CREATE VIEW view_CityInDictionary as
select c.CityID, c.City, c.CountryID, co.Country
from City as c inner join Country as co on c.CountryID = c.countryID
go

CREATE VIEW view_countriesInDictionary as 
select c.Country from Country as c
go


CREATE VIEW view_cancelledWorkshop as
select wd.WorkshopName, cd.ConferenceDate from Workshop as w
inner join WorkshopDictionary as wd
on wd.WorkshopDictionaryID = w.WorkshopDictionaryID
inner join ConferenceDay as cd
on cd.ConferenceDayID = w.ConferenceDayID
go

CREATE VIEW view_cancelledConferences as
select * 
from Conferences
where Cancelled = 1
go
