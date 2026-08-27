SELECT DATE_TRUNC('month', start) AS month,
       COUNT(DISTINCT master_id) AS count_mau,
       COUNT(DISTINCT CASE WHEN market = 'US' THEN master_id END) AS count_mau_us,
       COUNT(DISTINCT CASE WHEN market LIKE '%Strategic%' THEN master_id END) AS count_mau_strategic,
       COUNT(DISTINCT CASE WHEN market = 'Rest of World' THEN master_id END) AS count_mau_row,
       COUNT(DISTINCT CASE WHEN life_stage = 'menstruating' OR life_stage IS NULL THEN master_id END) AS count_mau_period_tracking,
       COUNT(DISTINCT CASE WHEN life_stage = 'fertility' THEN master_id END) AS count_mau_conceive,
       COUNT(DISTINCT CASE WHEN life_stage = 'pregnant' THEN master_id END) AS count_mau_pregnancy
FROM der.sp_sessions
LEFT JOIN static.market_mapping ON sp_sessions.country_name = market_mapping.country
WHERE start >= '2018-01-01' AND start < '2023-01-01'
GROUP BY 1
HAVING month < '2023-01-01'
UNION ALL
SELECT DATE_TRUNC('month', session_start) AS month,
       COUNT(DISTINCT master_id) AS count_mau,
       COUNT(DISTINCT CASE WHEN market = 'US' THEN master_id END) AS count_mau_us,
       COUNT(DISTINCT CASE WHEN market LIKE '%Strategic%' THEN master_id END) AS count_mau_strategic,
       COUNT(DISTINCT CASE WHEN market = 'Rest of World' THEN master_id END) AS count_mau_row,
       COUNT(DISTINCT CASE WHEN mode = 'period tracking' OR mode IS NULL THEN master_id END) AS count_mau_period_tracking,
       COUNT(DISTINCT CASE WHEN mode = 'conceive' THEN master_id END) AS count_mau_conceive,
       COUNT(DISTINCT CASE WHEN mode = 'pregnancy' THEN master_id END) AS count_mau_pregnancy
FROM der.sessions
left join "static".market_mapping on cast(sessions.country_name as varchar) = cast(market_mapping.country as varchar)
WHERE session_start >= '2023-01-01' AND session_start < DATE_TRUNC('month', CURRENT_DATE)
GROUP BY 1
ORDER BY 1 DESC
;