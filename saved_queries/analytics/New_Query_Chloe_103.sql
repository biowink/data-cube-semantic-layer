-- select
--     platform,
--     subscription_duration,
--     price_bucket,
--     sum(new_subscriptions) as users,
--     SUM(net_revenue) as ltv
-- from der.ltv_copy
-- group by 1, 2, 3
-- order by 1, 2, 3
-- ;

--------------------------- der.ltv
-- WITH most_recent_run AS (
-- SELECT MAX(created_execution_date) as most_recent_run
-- FROM der.ltv
-- ),

-- last_month AS (
-- SELECT subscription_duration, 
--     MAX(retention_curve) as last_month
-- FROM der.ltv
-- GROUP BY 1
-- )

-- SELECT
--     ltv.subscription_duration,
--     ltv.ltv
-- FROM der.ltv
-- JOIN most_recent_run mrr ON (ltv.created_execution_date = mrr.most_recent_run)
-- JOIN last_month lm ON (ltv.subscription_duration = lm.subscription_duration AND ltv.retention_curve = lm.last_month)
-- ;



--------------------------- der.ltv_copy
SELECT
    ltv.subscription_duration,
    platform,
    price_bucket,
    retention_curve,
    new_subscriptions,
    renewal_rate,
    ltv
FROM der.ltv_copy ltv

ORDER BY 1, 2, 3
;
