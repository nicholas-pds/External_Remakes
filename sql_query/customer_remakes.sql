SELECT
    cu.PracticeName,
    COUNT(ca.CaseID) AS Cases,
    COUNT(
        CASE
            WHEN NULLIF(LTRIM(RTRIM(remake)), '') IS NOT NULL THEN 1
        END
    ) AS Remakes
FROM
    dbo.cases AS ca
INNER JOIN
    dbo.customers AS cu ON ca.CustomerID = cu.CustomerID
WHERE
    invoicedate >= DATEADD(DAY, -91, CAST(GETDATE() AS DATE)) -- last 91 days
GROUP BY
    cu.PracticeName
ORDER BY
    cu.PracticeName;