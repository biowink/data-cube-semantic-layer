SELECT COUNT(DISTINCT analytics_id)
FROM der.clue_plus_user_lifetimes
LEFT OUTER JOIN user_metrics.user_last_optional_consent_status USING (analytics_id)
WHERE mode = 'perimenopause'
  AND is_dau
  AND date >= CURRENT_DATE - INTERVAL '60' DAY
  AND consent_scientific_research = true
  AND consent_usage_analytics = true
  AND consent_health_analytics = true
;