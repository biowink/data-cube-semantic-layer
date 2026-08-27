SELECT 
    date_trunc('day', derived_tstamp) as dt,
    COALESCE(NULLIF(JSON_EXTRACT_SCALAR(events.event_properties, '$["Canvas Id"]'), ''),
        NULLIF(JSON_EXTRACT_SCALAR(events.event_properties, '$["Campaign Id"]'), '')) AS campaign_or_canvas_id,
    count(1)
    
FROM der.events
where derived_tstamp >= date '2025-07-01'
and mobile_event_name = 'Subscription Started'
AND navigation_context IN (
    'deep link',
    'email',
    'in-app-message',
    'push',
    'deep-link-fallback',
    'push notification',
    'in app message',
    'deeplink'
    )
    
group by 1, 2 order by 1, 2