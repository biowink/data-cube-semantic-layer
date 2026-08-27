WITH missing_data AS (
    SELECT ret.*,
    CASE WHEN dup.platform is null then 1 else 0 end as missing
    FROM intermediate.subscriptions_retentions ret
    LEFT JOIN intermediate.subscriptions_retentions_duplicate dup USING(new_subscriptions, month_diff)
),

all_subsc AS (
SELECT subscription_id
FROM der.subscriptions_events
GROUP BY 1
),

all_raw_subsc AS (
SELECT subscription_id
FROM import.subscriptions_events
GROUP BY 1
)

SELECT platform, start_month,
    COUNT(new_subscriptions) as total_subscriptions,
    SUM(missing) as subscriptions_missing_from_subscriptions_retentions, 
    subscriptions_missing_from_subscriptions_retentions::float / total_subscriptions as pct_missing,
    COUNT(CASE WHEN missing = 1 THEN all_subsc.subscription_id ELSE NULL END) as num_of_missing_subscriptions_found_in_der_subscriptions_events,
    COUNT(CASE WHEN missing = 1 THEN all_raw_subsc.subscription_id ELSE NULL END) as num_of_missing_subscriptions_found_in_raw_data
FROM missing_data
LEFT JOIN all_subsc on missing_data.new_subscriptions = all_subsc.subscription_id
LEFT JOIN all_raw_subsc on missing_data.new_subscriptions = all_raw_subsc.subscription_id
GROUP BY 1, 2
ORDER BY 1, 2
