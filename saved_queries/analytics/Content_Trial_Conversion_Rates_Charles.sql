WITH content_trials AS (
SELECT analytics_id,
       events.derived_tstamp AS trial_start,
       events.platform,
       is_purchased
FROM der.events
INNER JOIN der.subscription_history USING (analytics_id)
WHERE mobile_event_name = 'Subscription Started'
    AND navigation_context = 'content articles'
    AND derived_tstamp BETWEEN DATE '2025-01-01' AND DATE '2025-10-01'
    AND DATE(derived_tstamp) = DATE(started_at)
    AND has_trial
    AND subscription_duration = 12
),
    trial_articles AS (
SELECT
    content_trials.analytics_id,
    content_trials.platform,
    content_trials.is_purchased,
    COUNT(DISTINCT JSON_EXTRACT_SCALAR(event_properties, '$["Article ID"]')) AS count_article_visits
FROM content_trials
LEFT JOIN der.events ON content_trials.analytics_id = events.analytics_id
    AND mobile_event_name = 'Show Article'
    AND DATE_DIFF('day', trial_start, events.derived_tstamp) BETWEEN 0 AND 6
    AND events.derived_tstamp >= DATE '2025-01-01'
GROUP BY 1, 2, 3
)
SELECT
    LEAST(GREATEST(count_article_visits, 1), 10) AS trial_article_visits,
    platform,
    COUNT(*) AS count_trials,
    AVG(CASE WHEN is_purchased THEN 1.0 ELSE 0 END) AS trial_cvr
FROM trial_articles
GROUP BY 1, 2
ORDER BY 1, 2
;