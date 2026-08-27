SELECT
   run_date,
   event_name,
   COUNT(*) AS count_events
FROM import.com_helloclue_backend_events_1
WHERE run_date >= DATE '2026-06-01'
GROUP BY 1, 2