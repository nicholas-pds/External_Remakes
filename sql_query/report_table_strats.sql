SELECT
    cust.PracticeName,
    linked.CaseNumber AS [OG_CaseNumber],
    CAST(linked.ShipDate AS DATE) AS [OG_ShipDate],
    CAST(linked.DueDate AS DATE) AS [OG_DueDate],
    main.CaseNumber AS MainCaseNumber,
    CAST(main.ShipDate AS DATE) AS [ShipDate],

    -- Summary Data from T2 (Last 90 Days)
    ISNULL(T2.Cases, 0) AS TotalCases_90Days,
    ISNULL(T2.Remakes, 0) AS TotalRemakes_90Days,

    -- Calculated Remake Percentage
    CASE
        -- Check if TotalCases_90Days is 0 to prevent division by zero error
        WHEN ISNULL(T2.Cases, 0) = 0 THEN 0.00
        -- Otherwise, calculate the percentage
        ELSE (CAST(ISNULL(T2.Remakes, 0) AS DECIMAL(10, 2)) / ISNULL(T2.Cases, 0))
    END AS [Remake Percentage]
FROM
    dbo.CaseLinks AS links
INNER JOIN
    dbo.Cases AS main ON links.CaseID = main.CaseID
INNER JOIN
    dbo.Cases AS linked ON links.LinkCaseID = linked.CaseID
INNER JOIN
    dbo.Customers AS cust ON main.customerID = cust.customerID
-- Perform a LEFT JOIN to the second query (T2) based on PracticeName
LEFT JOIN
(
    -- **Derived Table (T2) - Case/Remake Counts for Last 90 Days**
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
        ca.InvoiceDate >= DATEADD(DAY, -91, CAST(GETDATE() AS DATE))
    GROUP BY
        cu.PracticeName
) AS T2 ON cust.PracticeName = T2.PracticeName
-- **Main Query Filter (Last 60 Days Remakes)**
WHERE
    links.Notes LIKE '%Remake Of%' -- Ensures Main vs OG is correct Casenumbers. 
    AND main.DateIn >= DATEADD(DAY, -60, CAST(GETDATE() AS DATE))
    AND main.[Status] IN ('In Production', 'Invoiced', 'On Hold')
    AND main.Remake <> 'Remake Full Charge' -- Excluding full-charge remakes
ORDER BY
    main.DateIn ASC;