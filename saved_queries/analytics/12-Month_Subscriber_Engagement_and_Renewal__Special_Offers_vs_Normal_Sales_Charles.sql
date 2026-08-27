WITH subscription_activity AS (
    SELECT
        subscription_history.master_id,
        subscription_history.platform,
        subscription_id,
        cumulative_subscription_duration,
        started_in_intro_offer_period,
        CASE WHEN market LIKE '%Strategic%' THEN 'Non-US Strategic' ELSE market END AS market,
        first_seen_dt,
        COUNT(DISTINCT CASE WHEN is_dau THEN date END) AS days_active,
        COUNT(DISTINCT CASE WHEN is_dau THEN DATE_TRUNC('month', date) END) AS months_active
    FROM der.subscription_history
    LEFT JOIN static.market_mapping
            ON subscription_history.country = market_mapping.country
    LEFT JOIN der.clue_plus_user_lifetimes
            ON subscription_history.master_id = clue_plus_user_lifetimes.master_id AND
               DATEDIFF('day', first_purchased_at::DATE, clue_plus_user_lifetimes.date) BETWEEN 0 AND 364
    WHERE
        first_purchased_at::DATE BETWEEN '2021-07-01' AND '2021-12-31'
        AND subscription_history.subscription_duration = 12
    GROUP BY 1, 2, 3, 4, 5, 6, 7
)
SELECT started_in_intro_offer_period,
       months_active,
       COUNT(*) AS count_users,
       COUNT(*)::FLOAT/total_count AS share_total,
       AVG(CASE WHEN cumulative_subscription_duration > 12 THEN 1::FLOAT ELSE 0 END) AS renewal_rate
FROM subscription_activity
LEFT JOIN (SELECT started_in_intro_offer_period, COUNT(*) AS total_count FROM subscription_activity WHERE months_active <= 13 GROUP BY 1) totals USING (started_in_intro_offer_period)
WHERE months_active <= 13
GROUP BY 1, 2, total_count
ORDER BY 1, 2
;