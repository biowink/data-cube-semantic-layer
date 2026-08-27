WITH uniques AS (
    SELECT 
        platform, 
        subscription_id, 
        COUNT(distinct product_id) AS unique_product_ids
    FROM der.subscriptions_events
    GROUP BY 1, 2
)

SELECT 
    platform, 
    CASE WHEN unique_product_ids > 1 THEN true ELSE false END as multiple_product_ids,
    COUNT(subscription_id) AS subscriptions
FROM uniques
GROUP BY 1, 2
ORDER BY 1, 2