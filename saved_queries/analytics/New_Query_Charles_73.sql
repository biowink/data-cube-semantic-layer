WITH offset_array AS (SELECT ROW_NUMBER() OVER() - 6 AS month_offset
                      FROM der.ltv
                      LIMIT 9),
     paid_subscribers AS (SELECT master_id,
                                 COUNT(DISTINCT subscription_id) AS subscription_count
                          FROM der.subscriptions_events
                          WHERE subscription_type = 'Subscription Purchased'
                            AND master_id IS NOT NULL
                          GROUP BY 1
                          HAVING subscription_count >= 1),
     subscriber_sessions AS (SELECT subs.master_id,
                                    subs.subscription_id,
                                    subs.product_id,
                                    subs.subscription_duration,
                                    subs.started_at::DATE                        AS started_dt,
                                    subs.expires_at::DATE                        AS expired_dt,
                                    expired_dt - started_dt                      AS days_subscribed,
                                    subs.platform,
                                    subs.country,
                                    users.first_seen::DATE AS first_seen_dt,
                                    sp_sessions.is_subscribed,
                                    sp_sessions.life_stage,
                                    sp_sessions.start::DATE                      AS session_dt,
                                    session_dt BETWEEN started_dt AND expired_dt AS is_during_sub,
                                    session_dt - started_dt                      AS days_since_start,
                                    session_dt - expired_dt                      AS days_since_expiry
                             FROM der.subscriptions_events subs
                                      INNER JOIN der.sp_users users USING (master_id)
                                      INNER JOIN paid_subscribers USING (master_id)
                                      INNER JOIN der.sp_sessions USING (master_id)
                             WHERE subscription_type = 'Subscription Expired')
SELECT DATE_TRUNC('month', expired_dt) AS month,
       month_offset,
       COUNT(DISTINCT master_id) AS churning_users,
       COUNT(DISTINCT CASE WHEN DATEDIFF('month', expired_dt, session_dt) = month_offset THEN master_id END)::FLOAT/
         COUNT(DISTINCT CASE WHEN month_offset >= 0 THEN master_id
             WHEN month_offset < 0 AND DATEDIFF('month', expired_dt, first_seen_dt) <= month_offset THEN master_id END) AS mau
FROM subscriber_sessions
CROSS JOIN offset_array
WHERE DATE_TRUNC('month', expired_dt) >= '2021-12-01'
GROUP BY 1, 2, 2
ORDER BY 1 DESC, 2
;