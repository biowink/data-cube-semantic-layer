-- CREATE TABLE IF NOT EXISTS der.reactivation_attribution (
--         session_id STRING,
--         analytics_id STRING,
--         session_start TIMESTAMP,
--         days_since_previous_session INT,
--         message_send_id STRING
--     )
--     LOCATION 's3://clue-data-prod-athena-iceberg-storage/iceberg/der/reactivation_attribution'
--     TBLPROPERTIES (
--     'table_type'='iceberg'
-- );

-- DELETE FROM der.reactivation_attribution;

INSERT INTO der.reactivation_attribution (
    session_id,
    analytics_id,
    session_start,
    days_since_previous_session,
    message_send_id
)
WITH filtered_braze_message_sends AS (
    SELECT id, analytics_id, tstamp
    FROM der.braze_message_sends
    WHERE tstamp BETWEEN TIMESTAMP '2024-12-20' AND TIMESTAMP '2025-05-01'
),

sessions_with_all_attributed_campaigns AS (
    SELECT
        reactivation_sessions.session_id,
        reactivation_sessions.analytics_id,
        reactivation_sessions.session_start,
        reactivation_sessions.days_since_previous_session,
        filtered_braze_message_sends.id as message_send_id,
        ROW_NUMBER() OVER (PARTITION BY reactivation_sessions.session_id ORDER BY filtered_braze_message_sends.tstamp DESC
                ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
          AS row_number
    FROM intermediate.reactivation_sessions
    LEFT JOIN filtered_braze_message_sends
        ON (reactivation_sessions.analytics_id = filtered_braze_message_sends.analytics_id
            AND reactivation_sessions.session_start > filtered_braze_message_sends.tstamp + INTERVAL '3' SECOND
            AND reactivation_sessions.session_start < filtered_braze_message_sends.tstamp + INTERVAL '7' DAY
              )
)

SELECT
    session_id, analytics_id, session_start, days_since_previous_session, message_send_id
FROM sessions_with_all_attributed_campaigns
WHERE row_number = 1
;


select
    campaign_or_canvas_name, channel, count(1)
    -- session_id, days_since_previous_session, session_start, tstamp
from der.reactivation_attribution
left join der.braze_message_sends on (reactivation_attribution.message_send_id = braze_message_sends.id)
-- where campaign_or_canvas_name = 'CRM0473_birthControlType_engage_IAM'
-- limit 20;
group by 1, 2 order by 3 desc;

-- select count(1), count(message_send_id)
-- from der.reactivation_attribution