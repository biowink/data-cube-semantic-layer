SELECT platform,
       analytics_id IS NULL AS is_analytics_id_missing,
       COUNT(*)
FROM der.events
WHERE mobile_event_name = 'Did Create Account' AND derived_tstamp >= CURRENT_DATE - 2
GROUP BY 1, 2
ORDER BY 1, 2
;