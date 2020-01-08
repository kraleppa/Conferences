--Views
CREATE VIEW view_countriesInDictionary as 
select c.Country from Country as c
go

CREATE VIEW view_cancelledWorkshop as
select wd.WorkshopName, cd.ConferenceDate from Workshop as w
inner join WorkshopDictionary as wd
on wd.WorkshopDictionaryID = w.WorkshopDictionaryID
inner join ConferenceDay as cd
on cd.ConferenceDayID = w.ConferenceDayID
