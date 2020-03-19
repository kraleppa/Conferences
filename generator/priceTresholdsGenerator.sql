--wygenerowanie poprawnych progow cenowych
select * into #tableC
from
 (
    Select ConferenceID as ID, StartDate,
           DATEADD(DAY,-ABS(CHECKSUM(NewId())) % (90 - 1) + 1, StartDate) AS ref,
    (ABS(CHECKSUM(NewId())) % 7 + 2 ) AS divider
    from Conferences
 ) as T
;with counter( number ) as (
    select 0 union all
    select 1 + number from counter where number < abs(checksum(NEWID())) % 91
)

insert into Prices
select A.id as ConferenceID, DATEADD(DAY,N.Number * A.divider,A.ref) AS StartDate,
       0.75 - (n.number + 1) * 0.05 as Discount
from #tableC as A
    join counter as n on n.number < abs(checksum(newid())) % 80 + 1


delete target
from prices as target
    inner join conferences as c
        on c.ConferenceID = target.ConferenceID
where target.StartDate >= c.StartDate
