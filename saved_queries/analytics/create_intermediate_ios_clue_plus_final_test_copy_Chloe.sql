--with the renamed type table, add the finance metrics
--DROP TABLE intermediate.ios_clue_plus_final CASCADE;

CREATE TABLE intermediate.ios_clue_plus_final_test_copy
DISTKEY (master_id)
SORTKEY (backend_created_at)
AS (
WITH
	add_country_state AS (
	SELECT
		DISTINCT
		ios_clue_plus_rename_type.*,
		master_id_device_map.master_id,
		sp_users.last_country_code AS country_code,
		sp_users.last_country_name AS country,
		CASE WHEN sp_users.last_country_name IN ('Canada', 'United States') THEN sp_users.last_region_code
			ELSE NULL
		END AS state
	FROM intermediate.ios_clue_plus_rename_type
	LEFT JOIN der.master_id_device_map USING (analytics_id)
	LEFT JOIN der.sp_users USING (master_id)
),
	add_currency_tax_fee AS (
	SELECT
		add_country_state.*,
		COALESCE (add_country_state.currency, cc.currency_code) AS customer_currency,
		COALESCE (CASE WHEN country IN ('Canada', 'United States') THEN state_tr.tax_rate ELSE tr.tax_rate END, 0) AS tax_rate
	FROM add_country_state
	LEFT JOIN static.country_and_currency cc
		ON LOWER(cc.country_name) = LOWER(add_country_state.country)
	LEFT JOIN intermediate.play_store_country_tax_rate tr
		ON country::TEXT = tr.country_name::TEXT
		AND DATE(add_country_state.backend_created_at) = DATE(tr.created_execution_date)
	LEFT JOIN intermediate.play_store_ca_us_state_tax_rate state_tr
		ON add_country_state.state::TEXT = state_tr.state::TEXT
		AND DATE(add_country_state.backend_created_at) = DATE(state_tr.created_execution_date)
),
	replace_null_price_with_backend_price AS (
	SELECT add_currency_tax_fee.*, COALESCE(price, median_price) AS price_edit
	FROM add_currency_tax_fee
	LEFT JOIN intermediate.ios_clue_plus_backend_product_price bpp ON
		add_currency_tax_fee.customer_currency = bpp.currency
		AND add_currency_tax_fee.product_id = bpp.product_id
)
SELECT
	DISTINCT subscription_id,
	transaction_id,
	INITCAP(REPLACE(original_subscription_type, '_', ' ')) AS original_subscription_type,
	INITCAP(REPLACE(subscription_type, '_', ' ')) AS subscription_type,
	platform,
	product_id,
	subscription_duration,
	CASE WHEN is_in_intro_offer_period IS TRUE THEN intro_price
		ELSE COALESCE(price_edit, median_price)
	END AS customer_price, --the price clue set up as a default price
	price_edit,
	customer_currency,
	rate AS currency_exchange_rate,
	r.tax_rate,
	ROUND(customer_price-(customer_price*1/(1+r.tax_rate)),2) AS tax,
	ROUND(tax/rate,2) AS tax_euro,
	CASE WHEN trl.tax_rate IS NULL THEN customer_price + tax
		ELSE customer_price
	END AS gross_sales,
	ROUND(gross_sales/rate,2) AS gross_sales_euro,
	ROUND(gross_sales-tax,2) AS sales_without_tax,
	ROUND(sales_without_tax/rate,2) AS sales_without_tax_euro,
	store_fee_rate,
	ROUND(sales_without_tax*store_fee_rate,2) AS store_fee,
	ROUND(store_fee/rate,2) AS store_fee_euro,
	gross_sales-tax-store_fee AS net_sales,
	ROUND(net_sales/rate,2) AS net_sales_euro,
	country,
	state,
	free_trial_ended,
	is_trial_period,
	is_in_intro_offer_period,
	user_id,
	master_id,
	analytics_id,
	idfa,
	adjust_device_id,
	backend_created_at,
	backend_updated_at,
	started_at,
	expires_at,
	FALSE as reactivation,
	NULL::FLOAT as days_to_reactivation
FROM replace_null_price_with_backend_price r
LEFT JOIN intermediate.ios_clue_plus_appstore_product_price app
    ON customer_currency = app.currency
	AND product_id = app.product_ids
LEFT JOIN rep.currency_exchange_rates fx_rates
    ON DATE(backend_created_at) = DATE(date)
	AND customer_currency = fx_rates.currency
LEFT JOIN intermediate.tax_rate_lookup trl
    USING (country_code)
	--to check which country do not support tax-inclusive
	--https://play.google.com/console/u/0/developers/7621288401202788313/app/4972177195734843387/subscriptions/
	--pick one product id and select view price in the price section
	--there you'll see the list of local prices for each country and tax rate
);

GRANT SELECT ON TABLE intermediate.ios_clue_plus_final_test_copy TO GROUP reader;
