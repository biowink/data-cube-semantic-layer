WITH subscribers AS (
    SELECT
        date,
        COUNT(*) AS count_paying_subscribers
    FROM der.clue_plus_user_lifetimes
    WHERE is_paid_subscribed
    GROUP BY 1
    ORDER BY 1
    ),
    subscribers_lagged AS (
        SELECT
            date,
            count_paying_subscribers,
            LAG(count_paying_subscribers) OVER (ORDER BY DATE ASC) AS lagged_count_paying_subscribers
        FROM subscribers
    ),
            milestones AS (
SELECT
    date,
    count_paying_subscribers
FROM subscribers_lagged
WHERE FLOOR(count_paying_subscribers *1.0/100000) > FLOOR(lagged_count_paying_subscribers *1.0/100000)
    AND date != DATE '2025-03-23'
UNION ALL
SELECT
    DATE('2020-09-18') AS date,
    100050 AS count_paying_subscribers
UNION ALL
SELECT
    DATE('2017-10-01') AS date,
    0 AS count_paying_subscribers
ORDER BY date
    ),
    date_lag AS (
SELECT date,
    lag(date) OVER (ORDER BY count_paying_subscribers ASC) AS lagged_date,
    count_paying_subscribers
FROM milestones
    )
SELECT FLOOR(count_paying_subscribers * 1.0/100000) * 100000 AS milestone,
       DATE_DIFF('day', lagged_date, date) AS days_to_hit_milestone
FROM date_lag
ORDER BY 1