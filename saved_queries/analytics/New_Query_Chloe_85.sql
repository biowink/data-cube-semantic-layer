-- -- since we can't divide conversions in Adjust by promotion/non promotion purchases, we look at our own data and calculate the % of purchases in each segment
-- -- that were a promotion. we can then use this promotion to get a weighted promo/non promo LTV value

-- -- this query calculates the promo share at a global level to sub in for countries with a small sample size and for SKAdNetwork (which is not broken out by country)

-- CREATE TABLE IF NOT EXISTS intermediate.global_promo_share (
--     date DATE ENCODE ZSTD,
--     platform VARCHAR ENCODE ZSTD,
--     subscription_duration INTEGER ENCODE AZ64,
--     share_of_purchases_with_promotion DOUBLE PRECISION ENCODE ZSTD
-- );

-- GRANT SELECT ON intermediate.global_promo_share TO GROUP reader;

-- TRUNCATE TABLE intermediate.globaL_promo_share;

-- INSERT INTO intermediate.global_promo_share (
--     date,
--     platform,
--     subscription_duration,
--     share_of_purchases_with_promotion
-- )
-- (
--     SELECT
--       DATE_TRUNC('day', backend_created_at) as date,
--       LOWER(platform) AS platform,
--       subscription_duration,
--       COUNT(CASE WHEN is_in_intro_offer_period is TRUE
--                  THEN subscription_id ELSE NULL END)::float
--           / COUNT(subscription_id)
--         AS share_of_purchases_by_promotion
--   FROM der.subscriptions_events
--   WHERE subscription_type = 'Subscription Purchased' AND subscription_duration in (12, 1)
--   GROUP BY date, platform, subscription_duration
-- );

select * from intermediate.global_promo_share;