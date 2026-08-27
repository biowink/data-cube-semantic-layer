WITH first_subscription AS (
	SELECT master_id,
		subscription_duration,
		subscription_type,
		MIN(backend_created_at) AS first_subscription_date
	FROM der.subscriptions_events
	WHERE DATE_TRUNC('month', backend_created_at)::DATE >= DATE_TRUNC('month', '{{ execution_date }}'::DATE) - INTERVAL '3 months'
		AND subscription_type IN ('Subscription Free Trial', 'Subscription Purchased')
		AND subscription_duration in (12, 1)
	GROUP BY master_id,
		subscription_duration,
		subscription_type
)
SELECT
    '{{ execution_date }}'::TIMESTAMP AS prediction_created_date,
	subscription_duration,
	u.first_platform as platform,
	mm.country,
	COUNT(DISTINCT CASE WHEN first_subscription_date::DATE - first_seen::DATE = 0
	                    THEN s.master_id
	                    ELSE NULL END) AS d0_conversion_count,
	COUNT(DISTINCT CASE WHEN subscription_type = 'Subscription Purchased'
		                 AND first_subscription_date::DATE - first_seen::DATE BETWEEN 0 AND 7
		                THEN s.master_id
		                ELSE NULL END) AS d7_conversion_count,
	d7_conversion_count::FLOAT / NULLIF(d0_conversion_count,0) AS d7_to_d0_ccm
FROM der.sp_users u
JOIN intermediate.market_mapping mm ON (u.first_country_name = mm.country)
LEFT JOIN first_subscription s USING (master_id)
WHERE first_seen BETWEEN DATE_TRUNC('month', '{{ execution_date }}'::DATE) - INTERVAL '3 months'
	AND DATE_TRUNC('day', '{{ execution_date }}'::DATE) - INTERVAL '8 days'
	AND subscription_duration IS NOT NULL
	AND platform IS NOT NULL
	AND mm.market != 'Rest of World'
GROUP BY prediction_created_date, subscription_duration, platform, mm.country
ORDER BY prediction_created_date, subscription_duration, platform, mm.country