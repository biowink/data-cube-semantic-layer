SELECT AVG(CASE WHEN count_cramps > 0 THEN 1.0 ELSE 0 END) AS share_tracking_cramps
FROM
    (
        SELECT
            analytics_id,
            COUNT(DISTINCT category) AS count_categories,
            SUM(CASE WHEN category = 'pain' AND type IN ('period_cramps') THEN 1 ELSE 0 END) AS count_cramps
        FROM
            der.backend_tracking
        INNER JOIN user_metrics.user_last_optional_consent_status USING (analytics_id)
        INNER JOIN user_metrics.user_last_session_attributes USING (analytics_id)
        WHERE
            backend_updated_at >= CURRENT_DATE - INTERVAL '30' DAY
            AND consent_usage_analytics
            AND consent_health_analytics
            AND mode = 'period tracking'
        GROUP BY
            1
    )
WHERE count_categories > 1
;