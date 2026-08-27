WITH paid_active_users AS
  (SELECT master_id,
          MIN(START::DATE) AS first_paid_dt
   FROM der.sp_sessions
   WHERE is_subscribed
   GROUP BY 1 ),
     session_days AS
  ( SELECT master_id,
           START::DATE AS session_dt,
           MAX(is_subscribed::INT) AS is_subscribed
   FROM der.sp_sessions
   WHERE
     START >= '2021-01-01'
   GROUP BY 1,
            2 )
SELECT DATE_TRUNC('month', session_dt) AS MONTH,
       CASE
           WHEN is_subscribed THEN 'Paid DAU'
           WHEN NOT is_subscribed
                AND session_dt > first_paid_dt THEN 'Churned Free DAU'
           ELSE 'Free DAU'
       END AS user_type,
       COUNT(*) AS session_days
FROM session_days
LEFT JOIN paid_active_users USING (master_id)
GROUP BY 1,
         2
ORDER BY 1,
         2 DESC ;