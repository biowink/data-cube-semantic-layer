WITH strategic_market AS (
    SELECT country
    FROM static.market_mapping
    WHERE market IN ('US', 'Strategic Europe', 'Strategic w/o US and Europe')
), 
target_month_range AS (
    SELECT date_add('year', -1, MIN(month))::DATE AS starting_month FROM static.company_targets
)

SELECT
    DATE_TRUNC('month', session_start) AS month,
    COUNT(DISTINCT master_id) AS strategic_markets_existing_users
FROM der.sessions
LEFT JOIN der.sp_users USING (master_id)
WHERE
        DATE_TRUNC('month', session_start) >= (
        SELECT starting_month
        FROM target_month_range
    )
    AND session_start::DATE - first_seen::DATE > 30
    AND country_name IN (
    SELECT country
    FROM strategic_market
    )
GROUP BY 1