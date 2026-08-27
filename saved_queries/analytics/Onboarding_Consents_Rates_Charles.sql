SELECT platform,
       user_first_session_attributes.major_app_version,
       AVG(CASE WHEN consent_scientific_research THEN 1.0 ELSE 0 END) AS share_revoke_consent_scientific_research,
       AVG(CASE WHEN consent_health_analytics THEN 1.0 ELSE 0 END) AS share_revoke_consent_health_analytics,
       AVG(CASE WHEN consent_product_promotion THEN 1.0 ELSE 0 END) AS share_revoke_consent_product_promotion,
       AVG(CASE WHEN consent_usage_marketing THEN 1.0 ELSE 0 END) AS share_revoke_consent_usage_marketing,
       AVG(CASE WHEN consent_usage_analytics THEN 1.0 ELSE 0 END) AS share_revoke_consent_usage_analytics
FROM der.users
INNER JOIN user_metrics.user_first_session_attributes USING (analytics_id)
LEFT JOIN user_metrics.user_last_optional_consent_status USING (analytics_id)
WHERE account_created_at >= DATE '2025-01-01'
    AND platform IS NOT NULL
GROUP BY 1, 2
HAVING COUNT(*) > 10000
ORDER BY 1, 2
;