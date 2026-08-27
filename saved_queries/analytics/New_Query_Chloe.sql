with purchase_events as (
    select
        analytics_id,
        product_id,
        backend_created_at,
        subscription_type,
        gross_sales_euro,
        expires_at,
        LAG(subscription_type) OVER (PARTITION BY analytics_id ORDER BY backend_created_at) as last_subscription_type,
        LAG(expires_at) OVER (PARTITION BY analytics_id ORDER BY backend_created_at) as last_expires_at,
        LEAD(backend_created_at) OVER (PARTITION BY analytics_id ORDER BY backend_created_at) as next_transaction_at,
        LEAD(gross_sales_euro) OVER (PARTITION BY analytics_id ORDER BY backend_created_at) as next_purchase_gross_sales_euro
    from der.all_subscriptions_events
    where subscription_type in ('Subscription Purchased', 'Subscription Renewed')
    and subscription_duration = 12
    and subscription_source = 'mobile'
),

eight_weeks_cohort as (
    select *,
        date_add('day', 56, expires_at) as eight_weeks_post_expiration_at
    from purchase_events
    where (next_transaction_at is null
           OR next_transaction_at > date_add('day', 56, expires_at)
           )
),

renewals as (
    SELECT 
        analytics_id,
        eight_weeks_post_expiration_at,
        -- 30d
        CASE 
            WHEN next_transaction_at IS NOT NULL 
                 AND next_transaction_at <= DATE_ADD('day', 30, eight_weeks_post_expiration_at)
                 AND date_add('day', 30, eight_weeks_post_expiration_at) < current_date 
            THEN 1 
            ELSE 0 
        END AS renewed_within_30d,
        CASE 
            WHEN next_transaction_at IS NOT NULL 
                 AND next_transaction_at <= DATE_ADD('day', 30, eight_weeks_post_expiration_at)
                 AND date_add('day', 30, eight_weeks_post_expiration_at) < current_date 
            THEN next_purchase_gross_sales_euro
            ELSE 0 
        END AS gross_sales_euro_within_30d,
        -- 7d
        CASE 
            WHEN next_transaction_at IS NOT NULL 
                 AND next_transaction_at <= DATE_ADD('day', 7, eight_weeks_post_expiration_at)
                 AND date_add('day', 7, eight_weeks_post_expiration_at) < current_date 
            THEN 1 
            ELSE 0 
        END AS renewed_within_7d,
        CASE 
            WHEN next_transaction_at IS NOT NULL 
                 AND next_transaction_at <= DATE_ADD('day', 7, eight_weeks_post_expiration_at)
                 AND date_add('day', 7, eight_weeks_post_expiration_at) < current_date
            THEN next_purchase_gross_sales_euro
            ELSE 0 
        END AS gross_sales_euro_within_7d,
        --60d
        CASE 
            WHEN next_transaction_at IS NOT NULL 
                 AND next_transaction_at <= DATE_ADD('day', 60, eight_weeks_post_expiration_at)
                 AND date_add('day', 60, eight_weeks_post_expiration_at) < current_date
            THEN 1 
            ELSE 0 
        END AS renewed_within_60d,
        CASE 
            WHEN next_transaction_at IS NOT NULL 
                 AND next_transaction_at <= DATE_ADD('day', 60, eight_weeks_post_expiration_at)
                 AND date_add('day', 60, eight_weeks_post_expiration_at) < current_date
            THEN next_purchase_gross_sales_euro
            ELSE 0 
        END AS gross_sales_euro_within_60d,
        --90d
        CASE 
            WHEN next_transaction_at IS NOT NULL 
                 AND next_transaction_at <= DATE_ADD('day', 90, eight_weeks_post_expiration_at)
                 AND date_add('day', 90, eight_weeks_post_expiration_at) < current_date
            THEN 1 
            ELSE 0 
        END AS renewed_within_90d,
        CASE 
            WHEN next_transaction_at IS NOT NULL 
                 AND next_transaction_at <= DATE_ADD('day', 90, eight_weeks_post_expiration_at)
                 AND date_add('day', 90, eight_weeks_post_expiration_at) < current_date
            THEN next_purchase_gross_sales_euro
            ELSE 0 
        END AS gross_sales_euro_within_90d,
        --120d
        CASE 
            WHEN next_transaction_at IS NOT NULL 
                 AND next_transaction_at <= DATE_ADD('day', 120, eight_weeks_post_expiration_at)
                 AND date_add('day', 120, eight_weeks_post_expiration_at) < current_date
            THEN 1 
            ELSE 0 
        END AS renewed_within_120d,
        CASE 
            WHEN next_transaction_at IS NOT NULL 
                 AND next_transaction_at <= DATE_ADD('day', 120, eight_weeks_post_expiration_at)
                 AND date_add('day', 120, eight_weeks_post_expiration_at) < current_date
            THEN next_purchase_gross_sales_euro
            ELSE 0 
        END AS gross_sales_euro_within_120d
    FROM eight_weeks_cohort
)

SELECT 
    DATE_TRUNC('month', eight_weeks_post_expiration_at) as dt,
    COUNT(DISTINCT analytics_id) AS total_hit_8_weeks,
    --30d
    SUM(renewed_within_30d) AS renewed_within_30d_count,
    SUM(gross_sales_euro_within_30d) as gross_sales_euro_within_30d,
    ROUND(
        100.0 * SUM(renewed_within_30d) / NULLIF(COUNT(DISTINCT case when date_add('day', 30, eight_weeks_post_expiration_at) < current_date then analytics_id else null end), 0), 
        2
    ) AS pct_renewed_within_30d,
    SUM(gross_sales_euro_within_30d) / NULLIF(COUNT(DISTINCT case when date_add('day', 30, eight_weeks_post_expiration_at) < current_date then analytics_id else null end),0) 
        as average_gross_sales_per_churned_user_30d,
    --7d
    SUM(renewed_within_7d) AS renewed_within_7d_count,
    SUM(gross_sales_euro_within_7d) as gross_sales_euro_within_7d,
    ROUND(
        100.0 * SUM(renewed_within_7d) / NULLIF(COUNT(DISTINCT case when date_add('day', 7, eight_weeks_post_expiration_at) < current_date then analytics_id else null end), 0), 
        2
    ) AS pct_renewed_within_7d,
    SUM(gross_sales_euro_within_7d) / NULLIF(COUNT(DISTINCT case when date_add('day', 7, eight_weeks_post_expiration_at) < current_date then analytics_id else null end),0) 
        as average_gross_sales_per_churned_user_7d,
    --60d
    SUM(renewed_within_60d) AS renewed_within_60d_count,
    SUM(gross_sales_euro_within_60d) as gross_sales_euro_within_60d,
    ROUND(
        100.0 * SUM(renewed_within_60d) / NULLIF(COUNT(DISTINCT case when date_add('day', 60, eight_weeks_post_expiration_at) < current_date then analytics_id else null end), 0), 
        2
    ) AS pct_renewed_within_60d,
    SUM(gross_sales_euro_within_60d) / NULLIF(COUNT(DISTINCT case when date_add('day', 60, eight_weeks_post_expiration_at) < current_date then analytics_id else null end),0) 
        as average_gross_sales_per_churned_user_60d,
    --90d
    SUM(renewed_within_90d) AS renewed_within_90d_count,
    SUM(gross_sales_euro_within_90d) as gross_sales_euro_within_90d,
    ROUND(
        100.0 * SUM(renewed_within_90d) / NULLIF(COUNT(DISTINCT case when date_add('day', 90, eight_weeks_post_expiration_at) < current_date then analytics_id else null end), 0), 
        2
    ) AS pct_renewed_within_90d,
    SUM(gross_sales_euro_within_90d) / NULLIF(COUNT(DISTINCT case when date_add('day', 90, eight_weeks_post_expiration_at) < current_date then analytics_id else null end),0) 
        as average_gross_sales_per_churned_user_90d,
    --120d
    SUM(renewed_within_120d) AS renewed_within_120d_count,
    SUM(gross_sales_euro_within_120d) as gross_sales_euro_within_120d,
    ROUND(
        100.0 * SUM(renewed_within_120d) / NULLIF(COUNT(DISTINCT case when date_add('day', 120, eight_weeks_post_expiration_at) < current_date then analytics_id else null end), 0), 
        2
    ) AS pct_renewed_within_120d,
    SUM(gross_sales_euro_within_120d) / NULLIF(COUNT(DISTINCT case when date_add('day', 120, eight_weeks_post_expiration_at) < current_date then analytics_id else null end),0) 
        as average_gross_sales_per_churned_user_120d
FROM renewals
where eight_weeks_post_expiration_at between date '2025-01-01' and date '2026-08-01'
GROUP BY 1
ORDER BY 1 ASC;