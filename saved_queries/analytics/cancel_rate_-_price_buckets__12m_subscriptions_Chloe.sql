WITH
	promo_subs AS (
	SELECT
		backend_created_at::DATE AS subscription_date,
		first_seen::DATE AS first_seen_date,
		CASE WHEN (product_id LIKE '%promo%' OR is_in_intro_offer_period) THEN 'promo' ELSE 'non_promo' END AS promo,
		CASE WHEN subscription_duration = 12 THEN
		     CASE WHEN gross_sales_euro < 18 THEN '<18'
		          WHEN gross_sales_euro < 23 THEN '<23'
		          WHEN gross_sales_euro < 32 THEN '<32'
		          ELSE '>=32'
		          END
		     ELSE NULL END
		   AS price_bucket,
		subscription_id,
		subscription_duration,
		platform,
		country,
		product_id,
		master_id
	FROM
		der.subscriptions_events
		JOIN der.sp_users USING (master_id)
	WHERE
	    subscription_type IN('Subscription Purchased')
		AND master_id IS NOT NULL
		AND backend_created_at >= '2021-05-01'
	GROUP BY
		subscription_date,
		first_seen_date,
		promo,
		price_bucket,
		subscription_id,
		subscription_duration,
		platform,
		country,
		product_id,
		master_id
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
		AND backend_created_at BETWEEN '2021-05-01' AND current_date - '60 days'::interval
	),
	data AS (
    SELECT
    	subscription_date,
    	first_seen_date,
    	promo,
    	price_bucket,
    	subscription_id,
    	subscription_duration,
    	platform,
    	country,
    	product_id,
    	promo_subs.master_id,
    	cancelation_date,
    	cancelation.master_id AS canceled_user
    FROM promo_subs
    LEFT JOIN cancelation ON promo_subs.master_id = cancelation.master_id
    -- 	AND promo_subs.subscription_date <= cancelation.cancelation_date
        AND cancelation.cancelation_date BETWEEN promo_subs.subscription_date and promo_subs.subscription_date + '60 days'::interval 
    ),

final as (
SELECT
    DATE_TRUNC('month', subscription_date) AS month,
    price_bucket,
    promo,
    COUNT(DISTINCT master_id) AS users,
    COUNT(DISTINCT canceled_user) AS canceled_users,
    canceled_users::FLOAT/users AS cancel_rate
FROM data
WHERE subscription_duration = 12
GROUP BY month, price_bucket, promo
ORDER BY month, price_bucket, promo
)

select 
    price_bucket, promo,
    sum(users) as total_users,
    sum(canceled_users)::float / sum(users) as cancel_rate
from final
group by 1, 2
order by 1, 2