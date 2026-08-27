-- DROP TABLE intermediate.subscriptions_retentions_test;


CREATE TABLE IF NOT EXISTS intermediate.subscriptions_retentions_test (
    start_month TIMESTAMP WITH TIME ZONE ENCODE ZSTD,
    month_diff BIGINT ENCODE ZSTD,
    subscription_duration BIGINT ENCODE ZSTD,
    platform VARCHAR(50) ENCODE ZSTD,
    country VARCHAR ENCODE ZSTD,
    is_in_intro_offer_period BOOLEAN ENCODE ZSTD,
    new_subscriptions VARCHAR(36) ENCODE ZSTD,
    renewal VARCHAR(36) ENCODE ZSTD
);

TRUNCATE TABLE intermediate.subscriptions_retentions_test;

INSERT INTO intermediate.subscriptions_retentions_test (
    start_month,
    month_diff,
    subscription_duration,
    platform,
    country,
    is_in_intro_offer_period,
    new_subscriptions,
    renewal
)
(
WITH offsets AS (
	SELECT
		ROW_NUMBER() OVER () AS i
	FROM
		der.subscriptions_events
	LIMIT 36
),
new_subs AS (
SELECT
	started_at,
	subscription_id,
	subscription_duration,
	platform,
	country,
	is_in_intro_offer_period
FROM
	der.subscriptions_events
WHERE
	subscription_type = 'Subscription Purchased'
	AND backend_created_at < '2022-03-01'
GROUP BY
	started_at,
	subscription_id,
	subscription_duration,
	platform,
	country,
	is_in_intro_offer_period
),
renewal_subs AS (
SELECT
	backend_created_at,
	subscription_id
FROM
	der.subscriptions_events
WHERE
	subscription_type = 'Subscription Renewed'
	AND backend_created_at < '2022-03-01'
GROUP BY
	backend_created_at,
	subscription_id
)
SELECT
	DATE_TRUNC('month', started_at) AS start_month,
	offsets.i AS month_diff,
	subscription_duration,
	platform,
	country,
	is_in_intro_offer_period,
	new_subs.subscription_id AS new_subscriptions,
	CASE WHEN renewal_subs.subscription_id IS NOT NULL THEN
		renewal_subs.subscription_id
	END AS renewal
FROM
	new_subs
	JOIN offsets ON i < DATEDIFF('month', DATE(started_at), '2022-03-01')
	LEFT JOIN renewal_subs ON new_subs.subscription_id = renewal_subs.subscription_id
		AND DATEDIFF('month', DATE(started_at), DATE(renewal_subs.backend_created_at)) = offsets.i
WHERE
	started_at >= '2020-01-01'
GROUP BY
	DATE_TRUNC('month', started_at),
	month_diff,
	subscription_duration,
	platform,
	country,
	is_in_intro_offer_period,
	new_subscriptions,
	renewal
);

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- TABLE SCHEMA

-- DROP TABLE der.ltv_with_promo_test;

CREATE TABLE IF NOT EXISTS der.ltv_with_promo_test (
    subscription_duration BIGINT ENCODE ZSTD,
    platform VARCHAR(50) ENCODE ZSTD,
    is_in_intro_offer_period BOOLEAN ENCODE ZSTD,
    retention_curve BIGINT ENCODE ZSTD,
    renewal_rate DOUBLE PRECISION ENCODE ZSTD,
    renewal_periods BIGINT ENCODE ZSTD,
    gross_price DOUBLE PRECISION ENCODE ZSTD,
    gross_full_price DOUBLE PRECISION ENCODE ZSTD,
    predicted_rate DOUBLE PRECISION ENCODE ZSTD,
    revenue DOUBLE PRECISION ENCODE ZSTD,
    year_n BIGINT ENCODE ZSTD,
    net_revenue DOUBLE PRECISION ENCODE ZSTD,
    ltv DOUBLE PRECISION ENCODE ZSTD
);



INSERT INTO der.ltv_with_promo_test (
    subscription_duration,
    platform,
    is_in_intro_offer_period,
    retention_curve,
    renewal_rate,
    renewal_periods,
    gross_price,
    gross_full_price,
    predicted_rate,
    revenue,
    year_n,
    net_revenue,
    ltv
)
(
WITH
    offsets AS (
    SELECT ROW_NUMBER() OVER () - 1 AS month_diff
    FROM der.subscriptions_events
    LIMIT 36),

    sub_duration AS (
    SELECT DISTINCT subscription_duration, platform, is_in_intro_offer_period
    FROM der.subscriptions_events
    WHERE subscription_duration IS NOT NULL
    -- the line below is to filter out one error in the data that shows a promo for a 1 month subscription, which does not exist
        AND (subscription_duration != 1 OR is_in_intro_offer_period is not TRUE)),

    price AS (
    SELECT subscription_duration,
        platform,
        is_in_intro_offer_period,
        ROUND(AVG(gross_sales_euro), 2) AS gross_price,
        ROUND(AVG(gross_sales_full_price_euro), 2) AS gross_full_price
    FROM der.subscriptions_events
    WHERE subscription_type = 'Subscription Purchased'
        AND country IS NOT NULL
    GROUP BY subscription_duration, platform, is_in_intro_offer_period),

    all_renewal_rate AS (
    SELECT month_diff,
        subscription_duration,
        platform,
        CASE
            WHEN subscription_duration = 1 OR
                (subscription_duration = 6 AND month_diff IN (6,12,18,24)) OR
                (subscription_duration = 12 AND month_diff IN (12,24))
            THEN
                ROUND(COUNT(DISTINCT renewal)::FLOAT/COUNT(DISTINCT new_subscriptions)*100)
            ELSE
                NULL
        END AS renewal_rate
    FROM intermediate.subscriptions_retentions_test
    GROUP BY
        month_diff,
        subscription_duration,
        platform),

    predicted_revenue AS (
    SELECT subscription_duration,
        platform,
        is_in_intro_offer_period,
        month_diff AS retention_curve,
        CASE
            --add same month renewal rate as 100% to get full price
            WHEN month_diff = 0
                THEN 100
            WHEN is_in_intro_offer_period IS TRUE
                THEN renewal_rate * 0.9
            ELSE renewal_rate
        END AS renewal_rate,
        --create an offset to calculate the prediction rate using the last value of the renewal rate
        CASE
            WHEN month_diff = 0
                THEN NULL
            WHEN subscription_duration = 1 AND renewal_rate IS NULL
                THEN retention_curve - COUNT(renewal_rate) IGNORE NULLS OVER (
                    PARTITION BY subscription_duration, platform
                    ORDER BY subscription_duration, platform, month_diff
                    ROWS UNBOUNDED PRECEDING)
            WHEN subscription_duration IN (6,12) AND renewal_rate IS NULL
                AND MOD(retention_curve, subscription_duration) = 0
                THEN retention_curve / subscription_duration - COUNT(renewal_rate) IGNORE NULLS OVER (
                    PARTITION BY subscription_duration, platform
                    ORDER BY subscription_duration, platform, month_diff
                    ROWS UNBOUNDED PRECEDING)
            ELSE
                NULL
        END AS renewal_periods,
        gross_price,
        gross_full_price,
        CASE
            WHEN month_diff = 0
                THEN 100
            WHEN subscription_duration = 1 AND renewal_rate IS NULL
                THEN ROUND(LAST_VALUE(renewal_rate) IGNORE NULLS OVER (
                    PARTITION BY platform
                    ORDER BY subscription_duration, platform, month_diff
                    ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) * POW(0.95, renewal_periods))
            WHEN subscription_duration = 6 AND renewal_rate IS NULL
                THEN ROUND(LAST_VALUE(renewal_rate) IGNORE NULLS OVER (
                    PARTITION BY platform
                    ORDER BY subscription_duration, platform, month_diff
                    ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) * POW(0.75, renewal_periods))
            WHEN subscription_duration = 12 AND renewal_rate IS NULL
                THEN ROUND(LAST_VALUE(renewal_rate) IGNORE NULLS OVER (
                    PARTITION BY platform
                    ORDER BY subscription_duration, platform, month_diff
                    ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) * POW(0.85, renewal_periods))
        ELSE
            renewal_rate
        END AS predicted_rate,
        ROUND(
            CASE
                WHEN is_in_intro_offer_period AND month_diff != 0
                THEN gross_full_price * predicted_rate/100
            ELSE
                gross_price * predicted_rate/100
            END
            ,2) AS revenue
    FROM offsets
        CROSS JOIN sub_duration d
        LEFT JOIN all_renewal_rate r USING (month_diff, subscription_duration, platform)
        LEFT JOIN price p USING(subscription_duration, platform, is_in_intro_offer_period))

SELECT
    predicted_revenue.*,
    retention_curve / 12 AS year_n,
    CASE WHEN year_n = 0 THEN ROUND((revenue) * 0.7, 2) --store rate 1st year is 30%
        ELSE ROUND((revenue) * 0.85, 2) --store rate after 1st year is 15%
    END AS net_revenue,
    SUM(net_revenue) OVER (
        PARTITION BY subscription_duration, platform, is_in_intro_offer_period
        ORDER BY retention_curve
        ROWS UNBOUNDED PRECEDING) AS ltv
FROM predicted_revenue
WHERE predicted_rate IS NOT NULL
ORDER BY subscription_duration, platform
);


/*

Note on promotion renewal rate:
we have not reached 12 months since the start of our first promotions. we assume users that subscribed with a promotion
will be less likely to renew their subscription, so for now we are discounting their renewal rate by 10% (as seen in
lines 96-97). we will update this prediction after we get some initial data in July 2022.

*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



-- DROP TABLE der.ltv_per_country_test;

CREATE TABLE IF NOT EXISTS der.ltv_per_country_test (
    country VARCHAR ENCODE ZSTD,
    subscription_duration BIGINT ENCODE ZSTD,
    platform VARCHAR(50) ENCODE ZSTD,
    is_in_intro_offer_period BOOLEAN ENCODE ZSTD,
    retention_curve BIGINT ENCODE ZSTD,
    renewal_rate DOUBLE PRECISION ENCODE ZSTD,
    renewal_periods BIGINT ENCODE ZSTD,
    gross_price DOUBLE PRECISION ENCODE ZSTD,
    gross_full_price DOUBLE PRECISION ENCODE ZSTD,
    predicted_rate DOUBLE PRECISION ENCODE ZSTD,
    revenue DOUBLE PRECISION ENCODE ZSTD,
    year_n BIGINT ENCODE ZSTD,
    net_revenue DOUBLE PRECISION ENCODE ZSTD,
    ltv DOUBLE PRECISION ENCODE ZSTD
);


INSERT INTO der.ltv_per_country_test (
    country,
    subscription_duration,
    platform,
    is_in_intro_offer_period,
    retention_curve,
    renewal_rate,
    renewal_periods,
    gross_price,
    gross_full_price,
    predicted_rate,
    revenue,
    year_n,
    net_revenue,
    ltv
)
(
WITH
    offsets AS (
    SELECT ROW_NUMBER() OVER () - 1 AS month_diff
    FROM der.subscriptions_events
    LIMIT 36),

    sub_duration AS (
    SELECT DISTINCT subscription_duration, is_in_intro_offer_period
    FROM der.subscriptions_events
    WHERE subscription_duration IS NOT NULL
        AND (subscription_duration != 1 OR is_in_intro_offer_period is not TRUE)),

    sub_country AS (
    SELECT DISTINCT country, platform
    FROM der.subscriptions_events
    WHERE subscription_type = 'Subscription Purchased'
        AND country IS NOT NULL),

    price AS (
    SELECT country,
        subscription_duration,
        platform,
        is_in_intro_offer_period,
        ROUND(AVG(gross_sales_euro), 2) AS gross_price,
        ROUND(AVG(gross_sales_full_price_euro), 2) AS gross_full_price
    FROM der.subscriptions_events
    WHERE subscription_type = 'Subscription Purchased'
        AND country IS NOT NULL
    GROUP BY country, subscription_duration, platform, is_in_intro_offer_period),

    all_renewal_rate AS (
    SELECT month_diff,
        country,
        subscription_duration,
        platform,
        CASE WHEN subscription_duration = 1 OR
                (subscription_duration = 6 AND month_diff IN (6,12,18,24)) OR
                (subscription_duration = 12 AND month_diff IN (12,24))
            THEN ROUND(COUNT(DISTINCT renewal)::FLOAT/COUNT(DISTINCT new_subscriptions)*100)
            ELSE NULL
        END AS renewal_rate
    FROM intermediate.subscriptions_retentions_test
    WHERE country IS NOT NULL
    GROUP BY month_diff,
        country,
        subscription_duration,
        platform),

    predicted_revenue AS (
    SELECT
        country,
        subscription_duration,
        platform,
        is_in_intro_offer_period,
        month_diff AS retention_curve,
        CASE WHEN month_diff = 0
                THEN 100
             WHEN is_in_intro_offer_period IS TRUE
                THEN renewal_rate * 0.9
             ELSE renewal_rate END AS renewal_rate,
        CASE WHEN month_diff = 0 THEN NULL
            WHEN subscription_duration = 1 AND renewal_rate IS NULL
                THEN month_diff - COUNT(renewal_rate) IGNORE NULLS OVER (
                    PARTITION BY country, subscription_duration, platform
                    ORDER BY country, subscription_duration, platform, month_diff ROWS UNBOUNDED PRECEDING)
            WHEN subscription_duration IN(6, 12) AND renewal_rate IS NULL AND MOD(month_diff, subscription_duration) = 0
                THEN month_diff / subscription_duration - COUNT(renewal_rate) IGNORE NULLS OVER (
                    PARTITION BY country, subscription_duration, platform
                    ORDER BY country, subscription_duration, platform, month_diff ROWS UNBOUNDED PRECEDING)
            ELSE NULL
        END AS renewal_periods,
        gross_price,
        gross_full_price,
        CASE WHEN month_diff = 0 THEN 100
            WHEN subscription_duration = 1 AND renewal_rate IS NULL
                THEN ROUND(LAST_VALUE(renewal_rate) IGNORE NULLS OVER (
                    PARTITION BY country, subscription_duration, platform
                    ORDER BY country, subscription_duration, platform, month_diff
                    ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) * POW(0.95, renewal_periods))
            WHEN subscription_duration = 6 AND renewal_rate IS NULL
                THEN ROUND(LAST_VALUE(renewal_rate) IGNORE NULLS OVER (
                    PARTITION BY country, subscription_duration, platform
                    ORDER BY country, subscription_duration, platform, month_diff
                    ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) * POW(0.75, renewal_periods))
            WHEN subscription_duration = 12 AND renewal_rate IS NULL
                THEN ROUND(LAST_VALUE(renewal_rate) IGNORE NULLS OVER (
                    PARTITION BY country, subscription_duration, platform
                    ORDER BY country, subscription_duration, platform, month_diff
                    ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) * POW(0.85, renewal_periods))
            ELSE renewal_rate
        END AS predicted_rate,
        ROUND(
            CASE
                WHEN is_in_intro_offer_period AND month_diff != 0
                THEN gross_full_price * predicted_rate/100
            ELSE
                gross_price * predicted_rate/100
            END
            ,2) AS revenue
    FROM offsets
    CROSS JOIN sub_country
    CROSS JOIN sub_duration
    LEFT JOIN all_renewal_rate USING (month_diff, subscription_duration, country, platform)
    LEFT JOIN price USING (subscription_duration, country, platform, is_in_intro_offer_period))


SELECT predicted_revenue.*,
    retention_curve / 12 AS year_n,
    CASE WHEN year_n = 0 THEN ROUND((revenue) * 0.7, 2) --store rate 1st year is 30%
        ELSE ROUND((revenue) * 0.85, 2) --store rate after 1st year is 15%
    END AS net_revenue,
    SUM(net_revenue) OVER (
        PARTITION BY country, subscription_duration, is_in_intro_offer_period
        ORDER BY retention_curve ROWS UNBOUNDED PRECEDING) AS ltv
FROM predicted_revenue
WHERE predicted_rate IS NOT NULL
ORDER BY country, subscription_duration, platform, is_in_intro_offer_period, retention_curve
);


/*

Documentations:

renewal_periods or positive integer
we create a positive integer to calculate the rank of null renewal rate that needs to be predicted
-for 1m subs we need all 36 months renewal rate
-for 6m subs we only need renewal rate for the month 0, 6, 12, 18, 24, 30
-for 12m subs we only need renewal rate for the month 0, 12, 24
this explains why we need to substract the month difference with the non-null renewal rate

eg. if the renewal rate for 1m subs is only 20 complete months, we need to predict the renewal rate
from month 21 to month 35. we rank the month 21-35 starting from 1.
as we assume each new month is more or less 95% from the previous renewal rate, we can use the last non-null
value of renewal rate and create a predicted value by multiplying the last non value to 0.95^rank

---
formula:
month_n = last_value_renewal_rate * 0.95^rank
or
month_n = previous_renewal_rate * 0.95
---

---
% of last_value_renewal_rate by subscription duration:
1m = 95%
6m = 75%
12m = 85%
---

from the previous example:
month 21 = m20_renewal_rate * 0.95^1
month 22 = m20_renewal_rate * 0.95^2 -> this is the same as -> m21_predicted_renewal_rate * 0.95
...
month 35 = m20_renewal_rate * 0.95^15 -> this is the same as -> m34_predicted_renewal_rate * 0.95

---
promotion renewal rate:
we have not reached 12 months since the start of our first promotions. we assume users that subscribed with a promotion
will be less likely to renew their subscription, so for now we are discounting their renewal rate by 10% (as seen in
lines 103-104). we will update this prediction after we get some initial data in July 2022.

*/

