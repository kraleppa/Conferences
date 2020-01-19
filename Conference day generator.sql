--dodanie dni konferencji do konferencji
SELECT * INTO #TableA
FROM
    (
    SELECT ConferenceID AS ID,
    DATEDIFF(DAY, Conferences.StartDate, dbo.Conferences.EndDate) AS QUANTITY,
    Conferences.StartDate AS refColumn
    FROM Conferences
    ) T
;WITH Counter( Number ) AS (
    SELECT 0 UNION ALL
    SELECT 1 + Number FROM Counter WHERE Number < 10
    )
INSERT INTO dbo.ConferenceDay
SELECT A.ID AS ConferenceID,
    DATEADD(DAY, N.Number, A.refColumn) AS Date
FROM #TableA A
JOIN Counter N ON N.Number <= A.QUANTITY
ORDER BY A.ID, Date


/*SELECT * INTO #TableA
FROM
    (
    SELECT ReservationID AS ID,
        Conferences.ConferenceID,
        ConferenceDay.ConferenceDayID AS DAY,
        DATEDIFF(DAY, StartDate, EndDate) AS LENGTH
    FROM dbo.Reservation
        INNER JOIN dbo.Conferences
            ON Conferences.ConferenceID = Reservation.ConferenceID
        INNER JOIN dbo.ConferenceDay
            ON ConferenceDay.ConferenceID = Conferences.ConferenceID
    ) T
;WITH Counter ( Number ) AS (
    SELECT 0 UNION ALL
    SELECT 1 + Number FROM Counter WHERE Number < 3
)
INSERT INTO dbo.[Reservation Days]
SELECT DISTINCT
A.ID AS ReservationID,
A.DAY AS ConferenceDayID,
ABS(CHECKSUM(NewId())) % (40 - 10) + 10,
ABS(CHECKSUM(NewId())) % (40 - 10) + 10
FROM
#TableA A
JOIN
Counter N ON N.Number < A.LENGTH

select * from ConferenceDay*/