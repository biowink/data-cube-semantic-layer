SELECT DATE_TRUNC('week', last_canceled_at) AS week,
       COUNT(DISTINCT subscription_history.master_id) AS cancellers,
       COUNT(DISTINCT sp_sessions.master_id)::FLOAT/COUNT(DISTINCT subscription_history.master_id) AS share_mau,
       COUNT(start)::FLOAT/COUNT(DISTINCT subscription_history.master_id) AS avg_sessions
FROM der.subscription_history
LEFT JOIN der.sp_sessions ON subscription_history.master_id = sp_sessions.master_id
                                 AND start::DATE - last_canceled_at::DATE BETWEEN 1 AND 30
WHERE is_canceled AND last_canceled_at >= '2022-01-01'
GROUP BY 1
ORDER BY 1
;
