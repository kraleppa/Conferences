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