WITH yearly_subscribers AS (SELECT master_id,
                                   started_at,
                                   expires_at,
                                   subscription_id
                            FROM der.subscriptions_events
                            WHERE subscription_type = 'Subscription Purchased'
                              AND subscription_duration = 12
                              AND started_at BETWEEN '2021-01-01' AND '2021-08-01'
                              AND NOT reactivation),
     renewals AS (SELECT master_id,
                         GREATEST(DATEDIFF('day', sp_users.first_seen::DATE, yearly_subscribers.started_at::DATE), 0) AS days_to_convert,
                         yearly_subscribers.started_at::DATE                                         AS started_dt,
                         yearly_subscribers.expires_at::DATE                                         AS expires_dt,
                         MAX(CASE WHEN subscription_type = 'Subscription Renewed' THEN 1 ELSE 0 END) AS renewed
                  FROM yearly_subscribers
                      INNER JOIN der.sp_users USING (master_id)
                           LEFT JOIN der.subscriptions_events USING (subscription_id, master_id)
                  GROUP BY 1, 2, 3, 4)
SELECT CASE WHEN days_to_convert = 0 THEN 'D0'
            WHEN days_to_convert <= 7 THEN 'D1-7'
            WHEN days_to_convert <= 30 THEN 'D8-30'
            WHEN days_to_convert <= 365 THEN 'D31-365'
            WHEN days_to_convert <= 730 THEN 'Year 2'
            WHEN days_to_convert <= 1095 THEN 'Year 3'
            WHEN days_to_convert > 1095 THEN 'Year 4+'
       END AS conversion_bin,
    CASE WHEN days_to_convert = 0 THEN 1
            WHEN days_to_convert <= 7 THEN 2
            WHEN days_to_convert <= 30 THEN 3
            WHEN days_to_convert <= 365 THEN 4
            WHEN days_to_convert <= 730 THEN 5
            WHEN days_to_convert <= 1095 THEN 6
            WHEN days_to_convert > 1095 THEN 7
       END AS conversion_bin_index,
       COUNT(*) AS yearly_subscriber_count,
       AVG(renewed::FLOAT) AS renewal_rate
FROM renewals
GROUP BY 1, 2
ORDER BY 2
;