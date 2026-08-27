SELECT tracked_at::DATE AS date,
       tracked_event_type,
       COUNT(*) AS count_events,
       COUNT(DISTINCT analytics_id) AS count_users
FROM der.backend_gympass_event_tracked
GROUP BY 1, 2
ORDER BY 1 DESC, 2
;