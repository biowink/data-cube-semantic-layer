WITH b2b2c_users AS (
    SELECT
        users.analytics_id,
        users.account_created_at,
        COALESCE(all_subscriptions_events.partner, google_sheets_discount_code_metadata.partner) AS partner
    FROM der.users
    JOIN der.all_subscriptions_events 
      ON users.analytics_id = all_subscriptions_events.analytics_id
    LEFT JOIN airbyte.google_sheets_discount_code_metadata
      ON all_subscriptions_events.code = google_sheets_discount_code_metadata.code
    
    WHERE all_subscriptions_events.backend_created_at BETWEEN users.account_created_at AND DATE_ADD('day', 7, users.account_created_at)
     AND (all_subscriptions_events.partner IS NOT NULL OR google_sheets_discount_code_metadata.partner IS NOT NULL)
    
    GROUP BY 1, 2, 3
)

SELECT
    DATE_TRUNC('month', account_created_at) AS dt,
    partner,
    COUNT(analytics_id) AS users
FROM b2b2c_users
GROUP BY 1,2 ORDER BY 1,2