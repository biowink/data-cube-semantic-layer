WITH medical_records_data AS (
    SELECT
        u.analytics_id,
        CAST(json_parse(tracked_ids) AS map<VARCHAR, VARCHAR>) tracked_ids_mapped,
        mr.updated_at
    FROM
        import.airbyte_backend_medical_records mr
        INNER JOIN import.backend_users_raw u ON mr.user_id = u.id
        LEFT JOIN user_metrics.revoke_health_analytics_user rha
                  ON u.analytics_id = rha.analytics_id AND mr.updated_at > rha.consent_health_analytics_revoke_ts
    WHERE
        (rha.analytics_id IS NULL OR rha.analytics_id IN (
            SELECT DISTINCT analytics_id FROM der.backend_mode_switchers WHERE mode = 'CONCEIVE'
        ))
)
select
    analytics_id,
    key,
    value,
    updated_at
from medical_records_data
cross join unnest(map_keys(tracked_ids_mapped)) as t(key)
cross join unnest(map_values(tracked_ids_mapped)) as t(value)
WHERE analytics_id = 'clue-693c3039b68448a7ec537e6928926b4'
LIMIT 500
;