SELECT
    DATE(tstamp) AS date,
    COUNT(DISTINCT analytics_id) AS count_bounces
FROM der.braze_users_messages_email_bounce
WHERE 
    campaign_or_canvas_name = 'CRM0742_verificationEmail2025_email'
    AND tstamp >= DATE '2025-01-01'
GROUP BY 1
ORDER BY 1
LIMIT 500
;