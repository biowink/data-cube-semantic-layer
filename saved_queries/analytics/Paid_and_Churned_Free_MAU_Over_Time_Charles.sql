WITH paid_active_users AS (SELECT master_id,
                                  MIN(start::DATE) AS first_paid_dt
                           FROM der.sp_sessions
                           WHERE is_subscribed
                           GROUP BY 1
                           ),
    mau AS (
        SELECT master_id,
               DATE_TRUNC('month', start::DATE) AS session_dt,
               MAX(is_subscribed::INT) AS is_subscribed
        FROM der.sp_sessions
        WHERE start >= '2019-01-01'
        GROUP BY 1, 2
    )
SELECT DATE_TRUNC('month', session_dt) AS month,
       CASE
           WHEN is_subscribed THEN 'Paid MAU'
           WHEN NOT is_subscribed AND session_dt > first_paid_dt THEN 'Churned Free MAU'
           ELSE 'Free MAU'
       END AS user_type,
       COUNT(*) AS count_mau
FROM mau
LEFT JOIN paid_active_users USING (master_id)
WHERE month < DATE_TRUNC('month', CURRENT_DATE)
GROUP BY 1, 2
HAVING user_type != 'Free MAU' AND month >= '2021-01-01'
ORDER BY 1, 2 DESC
;