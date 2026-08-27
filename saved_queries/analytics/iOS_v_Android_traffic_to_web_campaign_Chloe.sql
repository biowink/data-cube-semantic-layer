
-- SELECT
--     platform, count(1), count(web_sessions.analytics_id)

-- FROM der.web_sessions
-- LEFT JOIN der.users ON (web_sessions.analytics_id = users.analytics_id)
-- LEFT JOIN user_metrics.user_last_session_attributes ON (web_sessions.analytics_id = user_last_session_attributes.analytics_id)
-- WHERE first_page_url like 'https://new.helloclue.com%' AND first_page_url like '%gad_campaignid%'
-- AND session_start >= CAST('2025-09-01' AS TIMESTAMP)
-- GROUP BY 1


SELECT
    -- date_trunc('day', collector_tstamp) as dt,
    case when useragent like '%iPhone%' then 'ios'
         when useragent like '%Android%' then 'android'
         else 'other' 
         end as os,
    count(distinct domain_userid)
FROM atomic_kinesis.events
WHERE platform = 'web'
AND collector_tstamp BETWEEN TIMESTAMP '2025-09-01' AND date '2025-09-15'
AND events.event_name = 'page_view'
AND page_url like '%new.helloclue.com%' and page_url like '%gad_campaignid%'
group by 1
order by 1, 2