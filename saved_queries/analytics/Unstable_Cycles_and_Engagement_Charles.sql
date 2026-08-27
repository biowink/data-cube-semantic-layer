WITH dau AS (
    SELECT
        perimenopause_user_population.master_id,
        COUNT(DISTINCT session_start::DATE) AS days_active
    FROM test.perimenopause_user_population
    LEFT JOIN der.sessions
            ON perimenopause_user_population.master_id = sessions.master_id AND
               DATEDIFF('day', session_start, CURRENT_DATE) BETWEEN 1 AND 30
    GROUP BY 1
)
SELECT is_comparison_group,
       count_recent_unstable_cycles_tracked,
       AVG(NVL(days_active, 0)::FLOAT/30) AS dau
FROM test.perimenopause_user_population
LEFT JOIN dau USING (master_id)
WHERE NOT has_profile_birth_control AND NOT has_tracking_birth_control
           AND perimenopause_user_population.count_initial_unstable_cycles_tracked = 0
           AND total_valid_cycles_tracked >= 20
GROUP BY 1, 2
ORDER BY 1, 2
;