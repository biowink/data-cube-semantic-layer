WITH unique_counts AS (
  SELECT 
    platform, 
    master_id, 
    COUNT(distinct subscription_id) AS unique_subscriptions
  FROM der.subscriptions_events
  WHERE master_id is not null
  GROUP BY 1, 2
)

SELECT 
    platform,
    CASE WHEN unique_subscriptions > 1 THEN true ELSE false END as more_than_one_subscription_id,
    count(master_id) as master_ids
FROM unique_counts
GROUP BY 1, 2
ORDER BY 1, 2