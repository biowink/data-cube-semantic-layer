WITH
	promo_subs AS (
	SELECT
		backend_created_at::DATE AS subscription_date,
		first_seen::DATE AS first_seen_date,
		CASE WHEN (product_id LIKE '%promo%' OR is_in_intro_offer_period) THEN 'promo' ELSE 'non_promo' END AS promo,
		subscription_id,
		subscription_duration,
		platform,
		country,
		product_id,
		master_id,
		reactivation
	FROM
		der.subscriptions_events
		JOIN der.sp_users USING (master_id)
	WHERE
	    subscription_type IN('Subscription Purchased')
		AND master_id IS NOT NULL
-- 		AND backend_created_at >= '2021-05-01'
		AND backend_created_at BETWEEN '2021-05-01' AND current_date - '90 days'::interval
	GROUP BY
		subscription_date,
		first_seen_date,
		promo,
		subscription_id,
		subscription_duration,
		platform,
		country,
		product_id,
		master_id,
		reactivation
	),

	cancelation AS (
	SELECT 
		backend_created_at::DATE AS cancelation_date,
		master_id
	FROM
		der.subscriptions_events
	WHERE
		subscription_type IN('Subscription Canceled')
		AND master_id IS NOT NULL
		AND backend_created_at >= '2021-05-01'
	),
	data AS (
    SELECT
    	subscription_date,
    	first_seen_date,
    	subscription_date - first_seen_date as days_to_subscription,
    	promo,
    	reactivation,
    	subscription_id,
    	subscription_duration,
    	platform,
    	country,
    	product_id,
    	promo_subs.master_id AS promo_user,
    	cancelation_date,
    	cancelation.master_id AS canceled_user
    FROM promo_subs
    LEFT JOIN cancelation ON promo_subs.master_id = cancelation.master_id
    -- 	AND promo_subs.subscription_date <= cancelation.cancelation_date
    	AND cancelation.cancelation_date BETWEEN promo_subs.subscription_date and promo_subs.subscription_date + '90 days'::interval
    WHERE days_to_subscription >= 0
    )
    
SELECT
    CASE WHEN days_to_subscription BETWEEN 0 and 7 THEN '1. 0-6'
         WHEN days_to_subscription BETWEEN 7 and 30 THEN '2. 7-30'
         WHEN days_to_subscription BETWEEN 30 and 90 THEN '3. 30-90'
         WHEN days_to_subscription BETWEEN 90 and 365 THEN '4. 90+'
         WHEN days_to_subscription > 365 THEN '5. 365+'
         ELSE days_to_subscription::varchar
         END as days_to_subscription_buckets,
    reactivation,
    promo,
    COUNT(DISTINCT promo_user) AS promo_users,
    COUNT(DISTINCT canceled_user) AS canceled_users,
    canceled_users::FLOAT/promo_users AS cancel_rate
FROM data
GROUP BY days_to_subscription_buckets, reactivation, promo
ORDER BY days_to_subscription_buckets, reactivation, promo