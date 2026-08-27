WITH attribution AS (
    SELECT *
    FROM (
        SELECT
            se.analytics_id,
            se.subscription_type,
            se.gross_sales_euro,
            se.backend_created_at,
            network_name,
            campaign_name,
                    ROW_NUMBER()
                    OVER (PARTITION BY se.analytics_id, se.subscription_type, se.gross_sales_euro, se.backend_created_at ORDER BY ai.created_at) AS rnk
        FROM der.subscriptions_events se
        INNER JOIN static.market_mapping mm
                ON se.country = mm.country
        LEFT JOIN import.users
                ON se.analytics_id = users.analytics_id
        LEFT JOIN import.backend_devices bd
                USING (user_id)
        LEFT JOIN der.adjust_install ai
                ON NVL(adjust_id, apple_idfa, google_ad_id) = NVL(adid, idfa, gps_adid)
        WHERE
                se.subscription_type IN ('Subscription Purchased', 'Subscription Renewed')
            AND DATE_TRUNC('month', se.backend_created_at) = '2023-09-01'
            AND mm.market != 'Rest of World'
    )
    WHERE
        rnk = 1
)
SELECT subscription_type,
       network_name,
       SUM(gross_sales_euro),
       SUM(gross_sales_euro)::FLOAT/(SELECT SUM(gross_sales_euro) FROM attribution) AS share_sales
FROM attribution
GROUP BY 1, 2
ORDER BY 1, 2
;