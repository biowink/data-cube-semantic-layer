WITH conceive_dau AS (
SELECT
    DATE(derived_tstamp) AS date,
    COUNT(DISTINCT analytics_id) AS count_users,
    COUNT(DISTINCT CASE WHEN mobile_event_name = 'Open Content Tab' THEN analytics_id END) * 1.0/
        COUNT(DISTINCT analytics_id) AS content_tab_rate,
    COUNT(DISTINCT CASE WHEN mobile_event_name IN ('Open Article', 'Show Article') THEN analytics_id END) * 1.0/
        COUNT(DISTINCT analytics_id) AS article_rate,
    COUNT(DISTINCT CASE WHEN mobile_event_name IN ('Session Started', 'Octopus Session Started') THEN analytics_id END) * 1.0/
        COUNT(DISTINCT analytics_id) AS octopus_rate,
    COUNT(DISTINCT CASE WHEN mobile_event_name IN ('Session Started', 'Octopus Session Started','Open Article', 'Show Article') THEN analytics_id END) * 1.0/
        COUNT(DISTINCT analytics_id) AS any_content_rate
FROM der.events
WHERE
    platform = 'android'
    AND "language" = 'English'
    AND country_name = 'United States'
    AND mode = 'conceive'
    AND derived_tstamp >= DATE '2026-05-01'
GROUP BY 1
)
SELECT
    DATE_TRUNC('week', date) AS week,
    AVG(content_tab_rate) AS content_tab_rate,
    AVG(article_rate) AS article_rate,
    AVG(octopus_rate) AS octopus_rate,
    AVG(any_content_rate) AS any_content_rate
FROM conceive_dau
GROUP BY 1
ORDER BY 1
;