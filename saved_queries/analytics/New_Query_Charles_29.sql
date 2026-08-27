WITH expired_subs AS (
    SELECT
        DATE_TRUNC('month', expires_at) AS churn_month,
        DATE_DIFF('month', started_at, last_canceled_at) AS cancellation_month,
        platform,
        COUNT(*) AS count_subs
    FROM
        der.subscription_history
    INNER JOIN der.users USING (analytics_id)
    WHERE
        is_purchased
        AND subscription_source = 'mobile'
        AND is_expired
        AND is_canceled
        AND subscription_duration = 12
        AND expires_at BETWEEN DATE '2024-01-01' AND DATE '2025-03-01'
        AND DATE_DIFF('day', started_at, expires_at) BETWEEN 360 AND 380
        AND DATE_DIFF('month', started_at, last_canceled_at) <= 12
        AND platform = 'ios'
        AND DATE_DIFF('day', account_created_at, started_at) >= 30
        AND started_in_intro_offer_period
    GROUP BY
        1,
        2,
        3
),
    expired_subs_totals AS (
        SELECT
            churn_month,
            SUM(count_subs) AS total_churners
        FROM
            expired_subs
        GROUP BY
            1
    )
SELECT churn_month,
       cancellation_month,
       count_subs,
       count_subs * 1.0/total_churners AS share_churners
FROM expired_subs
LEFT JOIN expired_subs_totals USING (churn_month)
ORDER BY 1, 2