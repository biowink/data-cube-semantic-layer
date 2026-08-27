SELECT DATE_TRUNC('week', derived_tstamp),
    SUM(CASE WHEN mobile_event_name = 'Select Send Verification Email' THEN 1.0 END)/
        SUM(CASE WHEN mobile_event_name = 'Did Create Account' THEN 1.0 END) AS avg_email_rate
FROM der.events
INNER JOIN der.users USING (analytics_id)
INNER JOIN user_metrics.user_onboarding_funnel USING (analytics_id)
WHERE derived_tstamp >= DATE '2024-09-01'
    AND mobile_event_name IN ('Select Send Verification Email', 'Did Create Account')
    AND DATE_DIFF('day', account_created_at, derived_tstamp) = 0
    AND user_onboarding_funnel.platform = 'android'
    AND did_create_account_method = 'email'
GROUP BY 1
ORDER BY 1
;