-- /*

-- TABLE SCHEMA

-- DROP TABLE intermediate.subscriptions_retentions_copy;

CREATE TABLE IF NOT EXISTS intermediate.subscriptions_retentions_copy (
    start_month TIMESTAMP WITH TIME ZONE ENCODE ZSTD,
    month_diff BIGINT ENCODE ZSTD,
    subscription_duration BIGINT ENCODE ZSTD,
    platform VARCHAR(50) ENCODE ZSTD,
    country VARCHAR ENCODE ZSTD,
    new_subscriptions VARCHAR(36) ENCODE ZSTD,
    renewal VARCHAR(36) ENCODE ZSTD,
    execution_date TIMESTAMP WITH TIME ZONE ENCODE ZSTD
);

-- */

-- TRUNCATE TABLE intermediate.subscriptions_retentions_copy;

INSERT INTO intermediate.subscriptions_retentions_copy (
    start_month,
    month_diff,
    subscription_duration,
    platform,
    country,
    new_subscriptions,
    renewal,
    execution_date
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
	country
FROM
	der.subscriptions_events
WHERE
	subscription_type = 'Subscription Purchased'
	AND backend_created_at <= '2022-03-01'
GROUP BY
	started_at,
	subscription_id,
	subscription_duration,
	platform,
	country
),
renewal_subs AS (
SELECT
	backend_created_at,
	subscription_id
FROM
	der.subscriptions_events
WHERE
	subscription_type = 'Subscription Renewed'
	AND backend_created_at <= '2022-03-01'
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
	new_subs.subscription_id AS new_subscriptions,
	CASE WHEN renewal_subs.subscription_id IS NOT NULL THEN
		renewal_subs.subscription_id
	END AS renewal,
	'2022-03-01'::timestamptz AS execution_date
FROM
	new_subs
	JOIN offsets ON i < DATEDIFF('month', DATE(started_at), CURRENT_DATE)
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
	new_subscriptions,
	renewal,
	execution_date
);
