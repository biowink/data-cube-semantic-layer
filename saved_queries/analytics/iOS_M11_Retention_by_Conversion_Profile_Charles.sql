WITH user_cohorts AS (
SELECT users.analytics_id,
       account_created_at,
       CASE
           WHEN DATE_DIFF('day', account_created_at, user_first_converted_at) < 30 AND NOT has_refund THEN 'Early Converter'
           WHEN DATE_DIFF('day', account_created_at, user_first_converted_at) < 365 OR partner IS NOT NULL THEN 'Late Converter'
            ELSE 'Non Converter'
        END AS conversion,
        network,
        user_first_session_attributes.platform,
        user_first_session_attributes.country_name
FROM der.users
LEFT JOIN der.subscription_history ON users.analytics_id = subscription_history.analytics_id
    AND user_converted_with_this_subscription
LEFT JOIN user_metrics.adjust_attribution ON users.analytics_id = adjust_attribution.analytics_id
INNER JOIN user_metrics.user_first_session_attributes ON users.analytics_id = user_first_session_attributes.analytics_id
WHERE account_created_at BETWEEN DATE '2023-06-01' AND DATE '2024-10-01'
)
SELECT DATE_TRUNC('month', account_created_at) AS cohort_month,
       conversion,
       COUNT(DISTINCT sessions.analytics_id) * 1.0/COUNT(DISTINCT user_cohorts.analytics_id) AS m11_retention_rate
FROM user_cohorts
LEFT JOIN der.sessions ON user_cohorts.analytics_id = sessions.analytics_id
                              AND DATE_DIFF('day', account_created_at, session_start) BETWEEN 330 AND 360
                            AND session_start >= DATE '2024-03-01'
WHERE conversion IN ('Early Converter', 'Non Converter') AND user_cohorts.platform = 'ios'
GROUP BY 1, 2
ORDER BY 1, 2
LIMIT 500
;