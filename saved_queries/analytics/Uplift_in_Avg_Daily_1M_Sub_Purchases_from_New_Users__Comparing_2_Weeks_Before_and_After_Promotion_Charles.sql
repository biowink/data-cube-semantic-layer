WITH promotion_sale_dates AS (
    SELECT
        date AS promotion_start_date
    FROM static.calendar
    WHERE
            date IN ('2021-07-03',
                     '2021-07-24',
                     '2021-09-25',
                     '2021-11-26',
                     '2021-12-26',
                     '2022-01-08',
                     '2022-02-14',
                     '2022-10-09',
                     '2022-11-25',
                     '2023-01-06',
                     '2023-01-23')
)
SELECT promotion_start_date,
       SUM(CASE WHEN DATEDIFF('day', promotion_start_date, backend_created_at::DATE) BETWEEN -16 AND -3
           THEN 1 END)::FLOAT/
       COUNT(DISTINCT CASE WHEN DATEDIFF('day', promotion_start_date, backend_created_at::DATE) BETWEEN -16 AND -3
           THEN backend_created_at::DATE END) AS avg_daily_1m_new_subs_presale,
       SUM(CASE WHEN DATEDIFF('day', promotion_start_date, backend_created_at::DATE) BETWEEN -1 AND 12
           THEN 1 END)::FLOAT/
       COUNT(DISTINCT CASE WHEN DATEDIFF('day', promotion_start_date, backend_created_at::DATE) BETWEEN -1 AND 12
           THEN backend_created_at::DATE END) AS avg_daily_1m_new_subs_postsale,
    (avg_daily_1m_new_subs_postsale::FLOAT/avg_daily_1m_new_subs_presale - 1) AS new_1m_sub_uplift
FROM promotion_sale_dates
INNER JOIN der.subscriptions_events ON DATEDIFF('day', promotion_start_date, backend_created_at::DATE) BETWEEN -16 AND 12
INNER JOIN der.sp_users USING (master_id)
WHERE DATEDIFF('day', first_seen::DATE, backend_created_at::DATE) BETWEEN -1 AND 1
    AND subscription_type IN ('Subscription Purchased')
    AND subscription_duration = 1
GROUP BY 1
ORDER BY 1
;