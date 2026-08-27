SELECT DATE_DIFF('year', birthday, date) AS age,
       COUNT(CASE WHEN type IN ('very_heavy') THEN analytics_id END) * 1.0/
       COUNT(analytics_id) AS share_bleeding_tracked_very_heavy
FROM der.profiles
INNER JOIN der.backend_tracking USING (analytics_id)
WHERE date >= CURRENT_DATE - INTERVAL '360' DAY
  AND category = 'period'
  AND DATE_DIFF('year', birthday, date) BETWEEN 14 AND 50
GROUP BY 1
ORDER BY 1
;