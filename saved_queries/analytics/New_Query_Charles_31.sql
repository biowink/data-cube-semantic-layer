WITH braze_email_campaigns AS (SELECT
            send.tstamp AS send_tstamp,
            send.id AS send_id,
            send.analytics_id AS send_analytics_id,
            send.campaign_or_canvas_id,
            send.campaign_or_canvas_name,
            send.variation_id,
            send.variation_name,
            send.step_id,
            send.step_name,
            send.message_type,
            send.channel,
            send.goal,
            open.tstamp AS open_tstamp,
            open.id AS open_id,
            open.analytics_id AS open_analytics_id,
            CASE WHEN open.machine_open = 'true' THEN open.id END AS machine_open_id,
            CASE WHEN open.machine_open = 'true' THEN open.analytics_id END AS machine_open_analytics_id,
            CASE WHEN open.machine_open is null THEN open.id END AS user_open_id,
            CASE WHEN open.machine_open is null THEN open.analytics_id END AS user_open_analytics_id
        FROM der.braze_users_messages_email_send send
        INNER JOIN user_metrics.user_first_session_attributes ON send.analytics_id = user_first_session_attributes.analytics_id
            LEFT JOIN der.braze_users_messages_email_open open
        ON COALESCE(send.campaign_or_canvas_id,'') = COALESCE(open.campaign_or_canvas_id,'')
            AND COALESCE(send.variation_id,'') = COALESCE(open.variation_id,'')
            AND COALESCE(send.step_id,'') = COALESCE(open.step_id,'')
            AND send.analytics_id = open.analytics_id
            AND send.tstamp <= open.tstamp
            AND DATE_DIFF('day', send.tstamp, open.tstamp) <= 1
            AND platform = 'android'
        WHERE send.message_type = 'campaign' AND LOWER(send.campaign_or_canvas_name) LIKE '%welcome%'
      )
SELECT
    DATE_TRUNC('week', braze_email_campaigns.send_tstamp) AS "braze_email_campaigns.email_sends_date",
    COUNT(DISTINCT braze_email_campaigns.open_id )  * 1.0 / COUNT(DISTINCT braze_email_campaigns.send_id ) AS open_rate
FROM braze_email_campaigns
WHERE DATE(braze_email_campaigns.send_tstamp) BETWEEN DATE '2024-10-01' AND DATE '2025-02-24'
GROUP BY
    1
ORDER BY
    1 DESC