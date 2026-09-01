SELECT
    DATE_TRUNC('week', currentmau.date) AS date,
    currentmau.platform,
    (SUM(count_sessions* 1.0)*30/7)/COUNT(DISTINCT CASE WHEN is_mau THEN analytics_id END) AS average_monthly_sessions
FROM der.clue_plus_user_lifetimes currentmau
WHERE
    currentmau.is_mau
    AND currentmau.is_clue_plus
    AND currentmau.mode = 'conceive'
    AND currentmau.country_name = 'United States'
    AND currentmau.language = 'English'
    AND currentmau.date BETWEEN DATE '2025-06-30' AND DATE_TRUNC('week', CURRENT_DATE) - INTERVAL '1' DAY
    AND currentmau.platform IN ('ios', 'android')
GROUP BY 1, 2
ORDER BY 1, 2
;