
WITH pregnancy_users AS (
    SELECT DISTINCT master_id
    FROM der.clue_plus_user_lifetimes
    WHERE is_paid_subscribed AND mode = 'pregnancy'
    AND date >= '2023-03-01'
    AND platform = 'ios'
),
    due_date_entries AS (
    SELECT
        master_id,
        JSON_EXTRACT_PATH_TEXT(event_properties, 'Pregnancy Due Date')::DATE AS pregnancy_due_date,
        derived_tstamp,
        ROW_NUMBER() OVER (PARTITION BY master_id ORDER BY derived_tstamp DESC) AS rnk
    FROM der.events
    WHERE
        mobile_event_name = 'Select Due Date'
        AND derived_tstamp >= '2023-01-01'
        AND JSON_EXTRACT_PATH_TEXT(event_properties, 'Pregnancy Due Date') != ''
        AND platform = 'ios'
),
    entered_due_date AS (
        SELECT master_id, pregnancy_due_date, derived_tstamp FROM due_date_entries WHERE rnk = 1
    ),
    cancellation_prep AS (
        SELECT
            master_id,
            backend_created_at::DATE AS cancellation_dt,
            pregnancy_due_date,
            DATEDIFF('month', cancellation_dt, pregnancy_due_date) AS month_relative_to_pregnancy
        FROM der.subscriptions_events
        INNER JOIN pregnancy_users
                USING (master_id)
        INNER JOIN entered_due_date
                USING (master_id)
        WHERE
            subscription_type = 'Subscription Canceled'
            AND subscription_duration = 12
            AND DATEDIFF('day', started_at::DATE, backend_created_at::DATE) > 30
            AND DATEDIFF('day', backend_created_at::DATE, expires_at::DATE) > 30
    )
SELECT month_relative_to_pregnancy,
       COUNT(*)::FLOAT/(SELECT COUNT(*) FROM cancellation_prep) AS share_total
FROM cancellation_prep
GROUP BY 1
ORDER BY 1
;
