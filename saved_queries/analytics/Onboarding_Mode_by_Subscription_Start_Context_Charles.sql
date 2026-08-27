WITH onboarding AS (
    SELECT
        first_select_onboarding_mode_mode,
        NVL(subscription_started_navigation_context, 'has not subscribed') AS subscription_started_navigation_context,
        COUNT(*) AS user_count
    FROM der.user_onboarding_funnel
    WHERE
        DATEDIFF('day', first_seen_ts, CURRENT_DATE) BETWEEN 3 AND 33
        AND first_select_onboarding_mode_mode IN ('period tracking', 'pregnancy', 'clue conceive')
    GROUP BY 1, 2
    ORDER BY 1, 3 DESC
),
    onboarding_indexed AS (
        SELECT
            first_select_onboarding_mode_mode,
            subscription_started_navigation_context,
            user_count,
                    ROW_NUMBER()
                    OVER (PARTITION BY first_select_onboarding_mode_mode ORDER BY user_count DESC) AS rnk
        FROM onboarding
    ),
    onboarding_aggregated AS (
        SELECT first_select_onboarding_mode_mode,
               SUM(user_count) AS total_user_count
        FROM onboarding
        GROUP BY 1
    )
SELECT first_select_onboarding_mode_mode,
       subscription_started_navigation_context,
       user_count::FLOAT/total_user_count
FROM onboarding_indexed
LEFT JOIN onboarding_aggregated USING (first_select_onboarding_mode_mode)
WHERE rnk BETWEEN 1 AND 5
ORDER BY 1, 3 DESC
;