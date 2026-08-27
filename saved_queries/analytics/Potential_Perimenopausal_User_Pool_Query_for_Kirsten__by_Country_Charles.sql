WITH older_eligible_users AS (
    SELECT
        analytics_id,
        country_name
    FROM user_metrics.user_last_session_attributes
    INNER JOIN der.profiles
            USING (analytics_id)
    INNER JOIN user_metrics.user_last_optional_consent_status
            USING (analytics_id)
    WHERE
        session_ts >= CURRENT_DATE - 60 -- Active in last 60 days
        AND DATEDIFF('year', birthday, CURRENT_DATE) >= 45 -- At least 45 years old
        AND consent_product_promotion -- Consent to product promotion
        AND consent_usage_analytics -- Consent to usage analytics
        AND user_last_session_attributes.mode != 'perimenopause' -- Not in Perimenopause mode already
        AND product_tier = 'free' -- Doesn't have Clue Plus already
),
    cycles AS (
        SELECT
            analytics_id,
            cycle_start,
            cycle_end,
            cycle_length,
            country_name,
            ROW_NUMBER() OVER (PARTITION BY analytics_id ORDER BY cycle_start DESC) AS rnk
        FROM older_eligible_users
        INNER JOIN der.backend_cycles
                USING (analytics_id)
        WHERE
            NOT cycle_excluded
            AND NOT cycle_predicted
            AND NOT current_cycle
    ),
    cycle_stats AS (
        SELECT
            analytics_id,
            country_name,
            MAX(cycle_end) AS most_recent_cycle,
            MAX(cycle_length) - MIN(cycle_length) AS cycle_variability
        FROM cycles
        WHERE
            rnk <= 10 -- Most recent 10 cycles
        GROUP BY 1, 2
    )
SELECT COUNT(DISTINCT CASE WHEN country_name = 'Germany' THEN analytics_id END)::FLOAT/COUNT(DISTINCT analytics_id) As potential_perimenopause_users
FROM cycle_stats
WHERE cycle_variability >= 7 -- Cycle Variability greater than 7 days in last 10 recorded cycles
  AND most_recent_cycle >= CURRENT_DATE - 90 -- Most recent completed cycle ended in last 90 days
;
