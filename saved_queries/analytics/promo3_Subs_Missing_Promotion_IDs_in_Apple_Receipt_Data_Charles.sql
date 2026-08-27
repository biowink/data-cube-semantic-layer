SELECT DATE_TRUNC('week', created_at::DATE) AS transaction_week,
       COUNT(*) AS count_subs,
       COUNT(CASE WHEN promotional_offer_id IS NULL THEN transaction_id END) AS count_subs_missing_promotional_ids
FROM import.apple_latest_receipt_info
WHERE
    product_id LIKE '%promo3%'
GROUP BY 1
ORDER BY 1 DESC
;