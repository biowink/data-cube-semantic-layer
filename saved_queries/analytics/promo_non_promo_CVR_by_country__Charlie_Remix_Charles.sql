WITH share_promotion_subscriptions AS (
SELECT
    DATE_TRUNC('hour', backend_created_at) as dt,
    AVG(CASE WHEN is_in_intro_offer_period THEN 1.0 ELSE 0.0 END) as share_promotion_subscriptions
FROM der.subscriptions_events
WHERE subscription_duration = 12 AND subscription_type = 'Subscription Purchased'
GROUP BY 1 ORDER BY 1
),

promotion_periods AS (
SELECT dt
FROM share_promotion_subscriptions
WHERE share_promotion_subscriptions >= 0.5
)

select
    country_name,
    -- date_trunc('day', session_start) as date,
    -- case when promotion_periods.dt is not null then 1 else 0 end as sale_period,
    
    count(distinct case when promotion_periods.dt is not null then analytics_id else null end) as sale_period_users,
    count(distinct case when promotion_periods.dt is not null and subscription_started_transaction_id is not null then analytics_id else null end) as sale_period_converted_users,
    100*sale_period_converted_users::float/NULLIF(sale_period_users,0) as sale_period_cvr_x100,
    
    count(distinct case when promotion_periods.dt is null then analytics_id else null end) as non_sale_period_users,
    count(distinct case when promotion_periods.dt is null and subscription_started_transaction_id is not null then analytics_id else null end) as non_sale_period_converted_users,
    100*non_sale_period_converted_users::float/NULLIF(non_sale_period_users,0) as non_sale_period_cvr_x100,
    sale_period_cvr_x100/NULLIF(non_sale_period_cvr_x100, 0) AS sale_to_non_sale_ratio

from der.sessions
join der.users using (analytics_id)
left join promotion_periods 
    ON (DATE_TRUNC('hour', sessions.session_start) = promotion_periods.dt)
    
where session_start >= '2024-01-01' 
  and account_created_at <= '2022-01-01'
  and (product_tier = 'free' OR subscription_started_transaction_id is not null)
  and count_view_subscription_plans > 0
 
group by 1
having sale_period_users > 1000
order by 2 descat