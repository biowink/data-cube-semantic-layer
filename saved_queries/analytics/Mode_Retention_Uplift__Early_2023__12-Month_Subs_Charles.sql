WITH activity_level AS (
    SELECT
        beforechurn.mode AS is_rh_mode,
        DATEDIFF('day', expires_at::DATE, lifetime.date) AS days_to_expiry,
        DATE_TRUNC('month', expires_at::DATE) AS expires_week,
        COUNT(lifetime.is_dau) AS count_users,
        AVG(CASE WHEN lifetime.is_dau THEN 1::FLOAT WHEN NOT lifetime.is_dau THEN 0 END) AS share_dau,
        AVG(CASE WHEN lifetime.is_wau THEN 1::FLOAT WHEN NOT lifetime.is_wau THEN 0 END) AS share_wau,
        AVG(CASE WHEN lifetime.is_mau THEN 1::FLOAT WHEN NOT lifetime.is_mau THEN 0 END) AS share_mau,
        AVG(CASE
                WHEN lifetime.is_paid_subscribed THEN 1::FLOAT
                WHEN NOT lifetime.is_paid_subscribed THEN 0
            END) AS share_paid
    FROM der.subscription_history
    INNER JOIN der.clue_plus_user_lifetimes beforechurn
            USING (analytics_id)
    INNER JOIN der.clue_plus_user_lifetimes lifetime
            USING (analytics_id)
    WHERE
        is_expired
        AND is_purchased
        AND subscription_history.platform = 'IOS'
        AND DATEDIFF('day', beforechurn.date, expires_at::DATE) = 1
        AND DATEDIFF('day', expires_at::DATE, lifetime.date) IN (-60, 60)
        AND expires_at::DATE BETWEEN '2022-09-01' AND '2023-06-15'
        AND beforechurn.mode IN ('conceive', 'period tracking', 'pregnancy')
        AND subscription_history.subscription_duration = 12
    GROUP BY 1, 2, 3
    ORDER BY 1, 2, 3
)
SELECT is_rh_mode,
       expires_week,
       AVG(CASE WHEN days_to_expiry = 60 THEN share_wau END) AS ending_wau,
       AVG(CASE WHEN days_to_expiry = 60 THEN share_mau END) AS ending_mau,
       AVG(CASE WHEN days_to_expiry = 60 THEN share_wau END)/
        AVG(CASE WHEN days_to_expiry = -60 THEN share_wau END) AS wau_uplift,
       AVG(CASE WHEN days_to_expiry = 60 THEN share_mau END)/
        AVG(CASE WHEN days_to_expiry = -60 THEN share_mau END) AS mau_uplift
FROM activity_level
GROUP BY 1, 2
ORDER BY 1, 2
;