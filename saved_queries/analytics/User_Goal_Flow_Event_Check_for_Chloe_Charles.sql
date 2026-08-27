
/*
Confluence documentation explaining these events is here (halfway down)

https://biowink.atlassian.net/wiki/spaces/DATA/pages/3673915393/Onboarding+and+Account+Management+Instrumentation+Rebirth

*/

SELECT platform,
       mobile_event_name,
       COUNT(*) AS count_events,
       COUNT(DISTINCT sp_device_id) AS count_users
FROM der.events
WHERE derived_tstamp >= DATE '2025-04-03'
    AND mobile_event_name IN (
        'Show User Goal Screen',
        'Select User Goal',
        'Show User Goal Error',
        'Assign Onboarding Mode',
        'Show Period Frequency Screen',
        'Select Period Frequency',
        'Show Onboarding Tracking Screen',
        'Select Onboarding Tracking Categories'
        )
GROUP BY 1, 2
ORDER BY 1, 2