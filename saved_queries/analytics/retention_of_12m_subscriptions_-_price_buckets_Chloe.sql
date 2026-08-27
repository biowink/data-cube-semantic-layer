WITH promo_subs AS (
	SELECT
		backend_created_at::DATE AS subscription_date,
		first_seen::DATE AS first_seen_date,
		CASE WHEN subscription_duration = 12 THEN
		     CASE WHEN gross_sales_euro < 18 THEN '<18'
		          WHEN gross_sales_euro < 23 THEN '<23'
		          WHEN gross_sales_euro < 32 THEN '<32'
		          ELSE '>=32'
		          END
		     ELSE NULL END
		   AS price_buckets,
		CASE WHEN (product_id LIKE '%promo%' OR is_in_intro_offer_period) THEN 'promo' ELSE 'non_promo' END AS promo,
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
		AND subscription_duration = 12
	GROUP BY
		subscription_date,
		first_seen_date,
		price_buckets,
		promo,
		subscription_id,
		subscription_duration,
		platform,
		country,
		product_id,
		master_id
)
SELECT
	DATE_TRUNC('month', promo_subs.subscription_date) AS subscription_month,
	price_buckets,
	promo,
    -- AVG(CASE WHEN promo = 'promo' then 1.0 else 0 end) as pct_promos,
	COUNT(DISTINCT master_id) AS total_subs,
	ROUND(COUNT(DISTINCT CASE WHEN start::DATE - subscription_date <= 30 THEN master_id ELSE NULL END)::FLOAT/total_subs * 100) AS m0,
	ROUND(COUNT(DISTINCT CASE WHEN start::DATE - subscription_date BETWEEN 31 AND 60 THEN master_id ELSE NULL END)::FLOAT/total_subs * 100) AS m1,
	ROUND(COUNT(DISTINCT CASE WHEN start::DATE - subscription_date BETWEEN 61 AND 90 THEN master_id ELSE NULL END)::FLOAT/total_subs * 100) AS m2,
	ROUND(COUNT(DISTINCT CASE WHEN start::DATE - subscription_date BETWEEN 91 AND 120 THEN master_id ELSE NULL END)::FLOAT/total_subs * 100) AS m3,
	ROUND(COUNT(DISTINCT CASE WHEN start::DATE - subscription_date BETWEEN 121 AND 150 THEN master_id ELSE NULL END)::FLOAT/total_subs * 100) AS m4,
	ROUND(COUNT(DISTINCT CASE WHEN start::DATE - subscription_date BETWEEN 151 AND 180 THEN master_id ELSE NULL END)::FLOAT/total_subs * 100) AS m5,
	ROUND(COUNT(DISTINCT CASE WHEN start::DATE - subscription_date BETWEEN 181 AND 210 THEN master_id ELSE NULL END)::FLOAT/total_subs * 100) AS m6,
	ROUND(COUNT(DISTINCT CASE WHEN start::DATE - subscription_date BETWEEN 211 AND 240 THEN master_id ELSE NULL END)::FLOAT/total_subs * 100) AS m7,
	ROUND(COUNT(DISTINCT CASE WHEN start::DATE - subscription_date BETWEEN 241 AND 270 THEN master_id ELSE NULL END)::FLOAT/total_subs * 100) AS m8,
	ROUND(COUNT(DISTINCT CASE WHEN start::DATE - subscription_date BETWEEN 271 AND 300 THEN master_id ELSE NULL END)::FLOAT/total_subs * 100) AS m9,
	ROUND(COUNT(DISTINCT CASE WHEN start::DATE - subscription_date BETWEEN 301 AND 330 THEN master_id ELSE NULL END)::FLOAT/total_subs * 100) AS m10,
	ROUND(COUNT(DISTINCT CASE WHEN start::DATE - subscription_date BETWEEN 331 AND 360 THEN master_id ELSE NULL END)::FLOAT/total_subs * 100) AS m11
FROM der.sp_sessions JOIN promo_subs USING (master_id) JOIN der.sp_users USING (master_id)
WHERE start >= '2021-05-01' AND start < DATE_TRUNC('month', CURRENT_DATE)
GROUP BY subscription_month, price_buckets, promo
ORDER BY subscription_month, price_buckets, promo
;