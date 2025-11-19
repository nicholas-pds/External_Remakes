SELECT
	main.DateIn as DateIn_TIME,
	CAST(linked.ShipDate AS DATE) AS [OG_ShipDate],
	CAST(linked.DueDate AS DATE) AS [OG_DueDate],
	linked.CaseNumber  AS [OG_CaseNumber],
    main.CaseNumber    AS MainCaseNumber,
	CAST(main.DateIn AS DATE) AS [DateIn],
	CAST(main.ShipDate AS DATE) AS [ShipDate],
	cust.PracticeName,
	main.TotalCharge,
	main.RemakeReason,
	main.Remake,
	main.RemakeDiscount,
	main.[Status]

FROM dbo.CaseLinks AS links
INNER JOIN dbo.Cases AS main   ON links.CaseID     = main.CaseID
INNER JOIN dbo.Cases AS linked ON links.LinkCaseID = linked.CaseID
INNER JOIN dbo.Customers AS cust ON main.customerID = cust.customerID

WHERE links.Notes LIKE '%Remake Of%'
AND main.DateIn >= DATEADD(DAY, -60, CAST(GETDATE() AS DATE))
AND main.[Status] IN ('In Production', 'Invoiced', 'On Hold')
--AND main.DateIn > '2025-11-22'
--AND main.DateIn < '2025-11-23'
ORDER BY main.DateIn ASC;

