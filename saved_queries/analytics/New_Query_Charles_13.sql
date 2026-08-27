SELECT
    DATE(purchase_date),
    COUNT(*)
FROM intermediate.ios_receipt_transactions
GROUP BY 1
ORDER BY 1 DESC
LIMIT 500
;