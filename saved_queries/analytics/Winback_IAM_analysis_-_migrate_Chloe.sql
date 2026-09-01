-- -- discounts/cancellation time
-- WITH iam_cohort AS (
--     -- Step 1: Identify all users who received the IAM, when they got it, and if they re-subscribed
--     SELECT 
--         b.analytics_id,
--         b.tstamp AS iam_send_tstamp,
--         CASE WHEN s.analytics_id IS NOT NULL THEN 1 ELSE 0 END AS has_resubscribed
--     FROM der.braze_message_sends b
--     JOIN user_metrics.user_last_session_attributes a on (b.analytics_id = a.analytics_id)
--     LEFT JOIN der.crm_subscription_started s 
--     ON b.campaign_or_canvas_id = s.campaign_or_canvas_id
--                 AND b.variation_id = s.variation_id
--                 AND b.step_id = s.step_id
--                 AND b.analytics_id = s.analytics_id
--                 AND (DATE_FORMAT(DATE(b.tstamp) , '%Y-%m-%d')) <= (DATE_FORMAT(s.tstamp , '%Y-%m-%d'))
--     WHERE b.campaign_or_canvas_name = 'CRM0163_SubExpiredV2_winback_canvas'
--     AND b.step_name IN ('SubExpiredIAM_gif', 'SubExpiredIAM')
--     AND b.tstamp <= current_date - interval '7' day
--     AND b.tstamp >= current_date - interval '360' day
--     AND a.platform = 'ios'
-- ),

-- latest_cancellation_before_iam AS (
--     -- Step 2: Find the most recent cancellation that happened BEFORE the IAM send
--     SELECT 
--         analytics_id,
--         iam_send_tstamp,
--         has_resubscribed,
--         cancellation_tstamp
--     FROM (
--         SELECT 
--             c.analytics_id,
--             c.iam_send_tstamp,
--             c.has_resubscribed,
--             e.backend_created_at AS cancellation_tstamp,
--             ROW_NUMBER() OVER (
--                 PARTITION BY c.analytics_id, c.iam_send_tstamp 
--                 ORDER BY e.backend_created_at DESC
--             ) AS rn
--         FROM iam_cohort c
--         JOIN der.all_subscriptions_events e 
--             ON c.analytics_id = e.analytics_id
--         WHERE e.subscription_type = 'Subscription Canceled'
--           AND e.backend_created_at < c.iam_send_tstamp -- Anchor 1: Must be before the IAM
--     )
--     WHERE rn = 1
-- ),

-- prior_purchase AS (
--     -- Step 3: Find the most recent purchase that happened BEFORE that specific cancellation
--     SELECT 
--         analytics_id,
--         iam_send_tstamp,
--         has_resubscribed,
--         cancellation_tstamp,
--         purchase_tstamp,
--         is_in_intro_offer_period
--     FROM (
--         SELECT 
--             c.analytics_id,
--             c.iam_send_tstamp,
--             c.has_resubscribed,
--             c.cancellation_tstamp,
--             p.backend_created_at AS purchase_tstamp,
--             p.is_in_intro_offer_period,
--             ROW_NUMBER() OVER (
--                 PARTITION BY c.analytics_id, c.iam_send_tstamp 
--                 ORDER BY p.backend_created_at DESC
--             ) AS rn
--         FROM latest_cancellation_before_iam c
--         JOIN der.all_subscriptions_events p 
--             ON c.analytics_id = p.analytics_id
--         WHERE p.subscription_type = 'Subscription Purchased'
--           AND p.backend_created_at < c.cancellation_tstamp -- Anchor 2: Must be before the cancellation
--           AND platform = 'ios'
--     )
--     WHERE rn = 1
-- ),

-- previous_sub_lifecycle AS (
--     -- Step 4: Calculate the days between that specific purchase and cancellation
--     SELECT 
--         analytics_id,
--         has_resubscribed,
--         is_in_intro_offer_period,
--         iam_send_tstamp,
--         cancellation_tstamp,
--         purchase_tstamp,
--         date_diff('day', CAST(purchase_tstamp AS TIMESTAMP), CAST(cancellation_tstamp AS TIMESTAMP)) AS days_to_cancel
--     FROM prior_purchase
-- )

-- -- Step 5: Aggregate data for correlation analysis
-- SELECT 
--     -- Behavior 1: Cancelled right away (e.g., within 30 days)
--     CASE WHEN days_to_cancel <= 30 THEN 'Cancelled Early (<=30 days)'
--          ELSE 'Cancelled Later (31+ days)' 
--     END AS cancellation_behavior,
    
--     -- Behavior 2: Purchased at a discount
--     CASE WHEN is_in_intro_offer_period = TRUE THEN 'Discounted Purchase'
--          ELSE 'Full Price Purchase' 
--     END AS purchase_type,

--     -- Metrics
--     COUNT(*) AS total_iam_recipients,
--     SUM(has_resubscribed) AS total_resubscriptions,
--     ROUND(100.0 * SUM(has_resubscribed) / COUNT(*), 2) AS conversion_rate_pct
-- FROM previous_sub_lifecycle
-- JOIN user_metrics.user_last_session_attributes on (previous_sub_lifecycle.analytics_id = user_last_session_attributes.analytics_id)
-- GROUP BY 1, 2
-- ORDER BY 1, 2;


-- -- countries
WITH iam_cohort AS (
    -- Step 1: Identify all users who received the IAM, when they got it, and if they re-subscribed
    SELECT 
        b.analytics_id,
        b.tstamp AS iam_send_tstamp,
        CASE WHEN s.analytics_id IS NOT NULL THEN 1 ELSE 0 END AS has_resubscribed
    FROM der.braze_message_sends b
    -- JOIN user_metrics.user_last_session_attributes a on (b.analytics_id = a.analytics_id)
    LEFT JOIN der.crm_subscription_started s 
    ON b.campaign_or_canvas_id = s.campaign_or_canvas_id
                AND b.variation_id = s.variation_id
                AND b.step_id = s.step_id
                AND b.analytics_id = s.analytics_id
                AND (DATE_FORMAT(DATE(b.tstamp) , '%Y-%m-%d')) <= (DATE_FORMAT(s.tstamp , '%Y-%m-%d'))
    WHERE b.campaign_or_canvas_name = 'CRM0163_SubExpiredV2_winback_canvas'
    AND b.step_name IN ('SubExpiredIAM_gif', 'SubExpiredIAM')
    AND b.tstamp <= current_date - interval '7' day
    AND b.tstamp >= current_date - interval '360' day
    -- AND a.platform = 'ios'
)

SELECT 
    user_last_session_attributes.country_name,
    COUNT(*) AS total_iam_recipients,
    SUM(has_resubscribed) AS total_resubscriptions,
    ROUND(100.0 * SUM(has_resubscribed) / COUNT(*), 2) AS conversion_rate_pct
FROM iam_cohort
JOIN user_metrics.user_last_session_attributes on (iam_cohort.analytics_id = user_last_session_attributes.analytics_id)
WHERE platform = 'ios'
GROUP BY 1 ORDER BY 2 DESC;