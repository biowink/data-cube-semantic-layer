-- CREATE TABLE test.change_mode_events
-- AS (
--     SELECT
--         sorted_events.*,
--         JSON_EXTRACT_PATH_TEXT(event_properties, 'Previous Mode') AS previous_mode,
--         JSON_EXTRACT_PATH_TEXT(event_properties, 'New Mode') AS new_mode,
--         JSON_EXTRACT_PATH_TEXT(event_properties, 'Change Trigger') AS change_trigger
--     FROM der.sorted_events
--     WHERE
--         mobile_event_name = 'Change Mode'
-- )
-- ;

WITH mode_changes AS (
    SELECT
        master_id,
        start,
        life_stage,
        LAG(life_stage) OVER (PARTITION BY master_id ORDER BY start) AS previous_life_stage,
        life_stage != previous_life_stage AS life_stage_change
    FROM der.sp_sessions
    WHERE
        life_stage IS NOT NULL
        AND start >= '2022-01-01'
)
SELECT DATE_TRUNC('month', start) AS month,
       life_stage,
       COUNT(change_mode_events.master_id)::FLOAT/COUNT(mode_changes.master_id) AS share_changes_with_events
FROM mode_changes
LEFT JOIN test.change_mode_events
        ON mode_changes.master_id = change_mode_events.master_id AND
           mode_changes.start::DATE = change_mode_events.derived_tstamp::DATE AND
           mode_changes.life_stage = change_mode_events.new_mode
WHERE
    life_stage_change
GROUP BY 1, 2
ORDER BY 1, 2
;