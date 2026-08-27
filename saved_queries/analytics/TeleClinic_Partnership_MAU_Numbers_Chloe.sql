-- https://looker.clue.run/explore/app_usage/events?qid=9ntjK3O09QuI2cPMbeX9oJ&origin_space=315
-- https://looker.clue.run/explore/app_usage/events?qid=CA33cVrOS0IKFsj2UxLisW&origin_space=315&toggle=dat,fil,vis

with irregular_cycles as (
    select analytics_id, TRUE as has_irregular_cycles
    from der.events
    where mobile_event_name = 'Select Period Frequency'
    and event_properties like '%"Period Frequency":"irregular"%'
    group by 1
)


select
    count(distinct analytics_id) AS total_germany_mau,
    count(distinct case when
                date_diff('year',profiles.birthday, current_date) >= 35 OR user_last_session_attributes.mode = 'perimenopause'
            then analytics_id else null end) as germany_mau_in_perimenopause_mode_or_35plus,
    count(distinct case when has_irregular_cycles
            then analytics_id else null end) as germany_mau_with_irregular_cycles,
    count(distinct case when backend_medical_records.endometriosis
            then analytics_id else null end) as germany_mau_with_endometriosis,
    count(distinct case when backend_medical_records.pcos
            then analytics_id else null end) as germany_mau_with_pcos,
    count(distinct case when user_last_session_attributes.mode = 'conceive'
            then analytics_id else null end) as germany_mau_in_conceive_mode

from der.sessions
left join user_metrics.user_last_optional_consent_status using (analytics_id)
left join der.profiles using (analytics_id)
left join user_metrics.user_last_session_attributes using (analytics_id)
left join user_metrics.backend_medical_records using (analytics_id)
left join irregular_cycles using (analytics_id)

where session_start >= current_date - interval '30' day
and consent_product_promotion 
and user_last_session_attributes.country_name = 'Germany'
