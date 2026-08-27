WITH modeswitchers AS (
    SELECT DISTINCT
        master_id
    FROM der.sp_sessions
             INNER JOIN der.sp_users
             USING (master_id)
    WHERE
          life_stage = 'fertility'
      AND start >= '2020-11-02'
      AND NOT is_test_user
),
     lagged_stages AS (
         SELECT
             master_id,
             start,
             life_stage,
             LAG(life_stage) OVER (PARTITION BY master_id ORDER BY start) AS previous_life_stage
         FROM modeswitchers
                  INNER JOIN der.sp_sessions
                  USING (master_id)
         WHERE
             life_stage IS NOT NULL
     ),
     segmentation AS (
         SELECT
             master_id,
             start,
             life_stage,
             previous_life_stage,
             SUM(CASE WHEN life_stage != previous_life_stage THEN 1 ELSE 0 END)
             OVER (PARTITION BY master_id ORDER BY start
                 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) + 1 AS stage_index
         FROM lagged_stages
     ),
    stage_agg AS (
        SELECT
            master_id,
            life_stage,
            stage_index,
            MIN(start)                  AS stage_start,
            COUNT(*)                    AS count_sessions,
            COUNT(DISTINCT start::DATE) AS count_sessions_days
        FROM segmentation
        GROUP BY 1, 2, 3
    ),
    switch_transitions AS (
        SELECT
            master_id,
            COUNT(life_stage) AS count_life_stage,
            LISTAGG(life_stage, ' -> ') WITHIN GROUP ( ORDER BY stage_index ) AS lifecycle
        FROM stage_agg
        GROUP BY 1
        HAVING count_life_stage > 1
    )
SELECT lifecycle,
       COUNT(*) AS count
FROM switch_transitions
GROUP BY 1
ORDER BY 2 DESC
;