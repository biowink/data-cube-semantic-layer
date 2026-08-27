WITH second_sessions AS (
    SELECT master_id, etl_created_at, session_id
    FROM der.sp_sessions
    WHERE session_index = 2 AND is_subscribed is not true
    and platform = 'ios'
    AND etl_created_at between current_date - '61 days'::interval and current_date - '1 day'::interval 
),

conversions AS (
    SELECT
        master_id, etl_created_at
    FROM der.sorted_events
    WHERE mobile_event_name = 'Subscription Started'
    and platform = 'ios'
    AND etl_created_at between current_date - '61 days'::interval and current_date - '1 day'::interval
),

funnel AS (
    SELECT
        cv.session_id,
        cv.master_id,
        cv.etl_created_at,
        MAX(CASE WHEN c.master_id IS NOT NULL THEN 1 ELSE 0 END) as converted
    FROM second_sessions cv
    LEFT JOIN conversions c ON (cv.master_id = c.master_id 
                                and c.etl_created_at between cv.etl_created_at and cv.etl_created_at + '1 day'::interval)
    GROUP BY 1, 2, 3
)

select
    count(distinct master_id) as unique_users,
    count(distinct case when converted = 1 then master_id else null end) as converted_users,
    converted_users::float/unique_users as cvr
FROM funnel

    