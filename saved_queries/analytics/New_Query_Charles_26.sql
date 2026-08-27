WITH age_groups AS (
    SELECT
        select_onboarding_mode_mode,
        DATE_DIFF('year', birthday, did_create_account_ts) AS age,
        COUNT(*) AS count_users
    FROM
        user_metrics.user_onboarding_funnel
        INNER JOIN der.profiles USING (analytics_id)
    WHERE
        select_onboarding_mode_mode IN ('nonbleeding', 'period tracking')
        AND analytics_id IS NOT NULL
        AND did_create_account_ts >= DATE '2025-01-01'
        AND DATE_DIFF('year', birthday, did_create_account_ts) BETWEEN 12 AND 55
    GROUP BY
        1,
        2
)
SELECT select_onboarding_mode_mode,
       age,
       count_users * 1.0/total_users AS share_users
FROM age_groups
INNER JOIN (SELECT select_onboarding_mode_mode, SUM(count_users) AS total_users FROM age_groups GROUP BY 1) AS group_totals
    USING (select_onboarding_mode_mode)