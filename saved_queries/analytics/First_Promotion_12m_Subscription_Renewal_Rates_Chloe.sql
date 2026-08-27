WITH new_subs AS (
    SELECT
    	started_at,
    	subscription_id,
    	platform,
    	is_in_intro_offer_period
    FROM
    	der.subscriptions_events
    WHERE
    	subscription_type = 'Subscription Purchased'
    	AND started_at BETWEEN '2021-07-01' and '2021-08-01'
    	AND ((started_at BETWEEN '2021-07-22' and '2021-07-28' and is_in_intro_offer_period is true)
    	 OR is_in_intro_offer_period is false)
    	AND subscription_duration = 12
    GROUP BY
    	started_at,
    	subscription_id,
    	platform,
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
GROUP BY
	backend_created_at,
	subscription_id
),

joined as (
    SELECT
    	DATE_TRUNC('month', started_at) AS start_month,
    	platform,
    	is_in_intro_offer_period,
    	new_subs.subscription_id AS new_subscriptions,
    	CASE WHEN renewal_subs.subscription_id IS NOT NULL THEN
    		renewal_subs.subscription_id
    		ELSE NULL
    	END AS renewal
    FROM new_subs
    	LEFT JOIN renewal_subs ON new_subs.subscription_id = renewal_subs.subscription_id
    		AND DATEDIFF('month', DATE(started_at), DATE(renewal_subs.backend_created_at)) = 12
)

SELECT 
    is_in_intro_offer_period,
    count(new_subscriptions) as subscriptions, 
    count(renewal) as renewals, 
    renewals::float/subscriptions as renewal_rate
from joined
GROUP BY 1
ORDER BY 1