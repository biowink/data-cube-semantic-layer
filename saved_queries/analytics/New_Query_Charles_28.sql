WITH purchases AS (
    SELECT
        subscription_id,
        analytics_id,
        account_created_at,
        platform,
        is_in_intro_offer_period,
        MIN(backend_created_at) AS first_purchased_at
    FROM
        der.mobile_subscriptions_events
        INNER JOIN der.users USING (analytics_id)
    WHERE
        subscription_type = 'Subscription Purchased'
        AND subscription_duration = 12
    GROUP BY
        1,
        2,
        3,
        4,
        5
),
    cancelations AS (
        SELECT
            purchases.subscription_id,
            purchases.analytics_id,
            account_created_at,
            first_purchased_at,
            purchases.platform,
            purchases.is_in_intro_offer_period,
            MIN(backend_created_at) AS first_canceled_at
        FROM
            purchases
            LEFT JOIN der.mobile_subscriptions_events
                ON purchases.subscription_id = mobile_subscriptions_events.subscription_id AND
                   mobile_subscriptions_events.backend_created_at > first_purchased_at
                       AND mobile_subscriptions_events.subscription_type = 'Subscription Canceled'
        GROUP BY
            1,
            2,
            3,
            4,
            5,
            6
    ),
    cross_numbers AS (
        SELECT date,
                ROW_NUMBER() OVER (ORDER BY date) - 1 AS months_since_purchase
        FROM static.calendar
        ORDER BY date
        LIMIT 12
    )
SELECT DATE_TRUNC('quarter', first_purchased_at) AS purchase_cohort,
       months_since_purchase,
       AVG(CASE WHEN DATE_DIFF('month', DATE(first_purchased_at), DATE(first_canceled_at)) <= months_since_purchase THEN 1.0 ELSE 0 END) AS cumulative_cancelation_rate
FROM cancelations
CROSS JOIN cross_numbers
WHERE first_purchased_at BETWEEN DATE '2023-01-01' AND DATE '2024-02-29'
    AND platform = 'IOS'
    AND is_in_intro_offer_period
GROUP BY 1, 2
ORDER BY 1, 2
;