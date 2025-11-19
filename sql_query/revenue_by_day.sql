SELECT
    CAST(InvoiceDate AS DATE) AS InvoiceDate,
    SUM(TaxableAmount + NonTaxableAmount) AS Revenue
FROM dbo.cases
WHERE [Status] NOT IN ('Cancelled', 'Submitted', 'Sent for TryIn')
  AND Deleted = 0
  AND [Type] = 'D'
  AND InvoiceDate >= DATEADD(DAY, -62, CAST(GETDATE() AS DATE))   -- last 62 days
  AND InvoiceDate < DATEADD(DAY, 1, CAST(GETDATE() AS DATE))      -- excludes tomorrow 
GROUP BY CAST(InvoiceDate AS DATE)
ORDER BY InvoiceDate DESC;