WITH unusual_cancelations AS
  (SELECT subscription_id
   FROM der.subscriptions_events
   WHERE subscription_type = 'Subscription Canceled'
     AND subscription_duration = 12
     AND is_trial_period
     AND DATE_DIFF('day', started_at::DATE, backend_created_at::DATE) = 66),
     subscription_logs AS
  (SELECT subscription_id,
          product_id,
          LISTAGG(REPLACE(subscription_type, 'Subscription ', ''), '-> ') WITHIN
   GROUP (
          ORDER BY backend_created_at) AS subscription_history
   FROM der.subscriptions_events
   INNER JOIN unusual_cancelations USING (subscription_id)
   GROUP BY 1,
            2)
SELECT product_id,
       subscription_history,
       COUNT(*) AS COUNT
FROM subscription_logs
GROUP BY 1,
         2
ORDER BY 3 DESC ;