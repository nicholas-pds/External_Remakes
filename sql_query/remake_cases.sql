SELECT
    main.DateIn AS DateIn_TIME,
    CAST(linked.ShipDate AS DATE) AS [OG_ShipDate],
    CAST(linked.DueDate AS DATE) AS [OG_DueDate],
    linked.CaseNumber AS [OG_CaseNumber],
    main.CaseNumber AS MainCaseNumber,
    CAST(main.DateIn AS DATE) AS [DateIn],
    CAST(main.ShipDate AS DATE) AS [ShipDate],
    cust.PracticeName,
    main.TotalCharge,
    main.RemakeReason,
    main.Remake,
    main.RemakeDiscount,
    main.[Status],
    -- Select the results from the joined subquery, using ISNULL/COALESCE
    -- to replace NULLs (no match) with 0s.
    ISNULL(T2.Cases, 0) AS TotalCases_90Days,
    ISNULL(T2.Remakes, 0) AS TotalRemakes_90Days,
    cust.SalesPerson,
    topProduct.ProductID AS Product
FROM
    dbo.CaseLinks AS links
INNER JOIN
    dbo.Cases AS main ON links.CaseID = main.CaseID
INNER JOIN
    dbo.Cases AS linked ON links.LinkCaseID = linked.CaseID
INNER JOIN
    dbo.Customers AS cust ON main.customerID = cust.customerID
-- LEFT JOIN to the second query (T2) based on PracticeName
LEFT JOIN
(
    -- **SECOND QUERY - Derived Table (T2)**
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
        ca.InvoiceDate >= DATEADD(DAY, -91, CAST(GETDATE() AS DATE)) -- last 91 days filter
    GROUP BY
        cu.PracticeName
) AS T2 ON cust.PracticeName = T2.PracticeName
OUTER APPLY
(
    SELECT TOP 1 cp.ProductID
    FROM dbo.CaseProducts AS cp
    WHERE cp.CaseID = linked.CaseID
    ORDER BY cp.UnitPrice DESC
) AS topProduct
-- **FIRST QUERY - WHERE Clause**
WHERE
    links.Notes LIKE '%Remake Of%'
    AND main.DateIn >= DATEADD(DAY, -60, CAST(GETDATE() AS DATE)) -- last 60 days filter
    AND main.[Status] IN ('In Production', 'Invoiced', 'On Hold')
ORDER BY
    main.DateIn ASC;