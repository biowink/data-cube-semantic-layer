WITH yearly_subscribers AS (SELECT master_id,
                                   started_at,
                                   expires_at,
                                   subscription_id
                            FROM der.subscriptions_events
                            WHERE subscription_type = 'Subscription Purchased'
                              AND subscription_duration = 12
                              AND started_at BETWEEN '2021-01-01' AND '2021-08-01'),
     renewals AS (SELECT master_id,
                         yearly_subscribers.started_at::DATE                                         AS started_dt,
                         yearly_subscribers.expires_at::DATE                                         AS expires_dt,
                         MAX(CASE WHEN subscription_type = 'Subscription Renewed' THEN 1 ELSE 0 END) AS renewed
                  FROM yearly_subscribers
                           LEFT JOIN der.subscriptions_events USING (subscription_id, master_id)
                  GROUP BY 1, 2, 3),
     cohort_sizes AS (SELECT renewed, COUNT(*) AS total_cohort FROM renewals GROUP BY 1),
     first_year_activity AS
         (SELECT renewed,
                 renewals.master_id,
                 LEAST(COUNT(DISTINCT DATE_TRUNC('month', start::DATE)), 13) AS session_months
          FROM renewals
                   LEFT JOIN der.sp_sessions ON renewals.master_id = sp_sessions.master_id AND
                                                sp_sessions.start::DATE BETWEEN started_dt AND started_dt + 364
          GROUP BY 1, 2)
SELECT CASE WHEN renewed = 1 THEN 'Renewer' ELSE 'Churner' END AS subscriber_status,
       session_months,
       COUNT(*)::FLOAT / total_cohort                          AS share_subscribers
FROM first_year_activity
         INNER JOIN cohort_sizes USING (renewed)
GROUP BY 1, 2, total_cohort
ORDER BY 1, 2
;