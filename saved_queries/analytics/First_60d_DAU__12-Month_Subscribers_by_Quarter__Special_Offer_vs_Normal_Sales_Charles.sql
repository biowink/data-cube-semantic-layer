WITH subscription_activity AS (
    SELECT
        subscription_history.master_id,
        subscription_history.platform,
        subscription_id,
        cumulative_subscription_duration,
        started_in_intro_offer_period,
        CASE WHEN market LIKE '%Strategic%' THEN 'Non-US Strategic' ELSE market END AS market,
        first_seen_dt,
        first_purchased_at,
        AVG(CASE WHEN is_dau THEN 1::FLOAT ELSE 0 END) AS dau
    FROM der.subscription_history
    LEFT JOIN static.market_mapping
            ON subscription_history.country = market_mapping.country
    LEFT JOIN der.clue_plus_user_lifetimes
            ON subscription_history.master_id = clue_plus_user_lifetimes.master_id AND
               DATEDIFF('day', first_purchased_at::DATE, clue_plus_user_lifetimes.date) BETWEEN 0 AND 59
    WHERE
        first_purchased_at::DATE BETWEEN '2021-07-01' AND '2022-12-31'
        AND subscription_history.subscription_duration = 12
    GROUP BY 1, 2, 3, 4, 5, 6, 7, 8
)
SELECT DATE_TRUNC('quarter', first_purchased_at) AS conversion_quarter,
       started_in_intro_offer_period,
       COUNT(*) AS count_users,
       AVG(dau) AS average_first60d_paid_dau,
       MEDIAN(dau) AS median_first60d_paid_dau
FROM subscription_activity
GROUP BY 1, 2
ORDER BY 1, 2
;