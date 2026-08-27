WITH perimenopause_users AS (
    SELECT *
    FROM temp.perimenopause_user_population
    WHERE
        NOT has_profile_birth_control
        AND NOT has_tracking_birth_control
        AND DATEDIFF('day', most_recent_valid_cycle_end, CURRENT_DATE) <= 90
        AND NOT is_comparison_group
        -- AND count_recent_unstable_cycles_tracked >= 2
        AND perimenopause_user_population.count_initial_unstable_cycles_tracked = 0
        AND total_valid_cycles_tracked >= 20
)
SELECT
    count_recent_unstable_cycles_tracked,
    is_comparison_group,
    COUNT(*) AS count_users,
    COUNT(*)::FLOAT / total AS share_total
FROM perimenopause_users
LEFT JOIN (
    SELECT is_comparison_group, COUNT(*) AS total FROM perimenopause_users GROUP BY 1
) grand_total
        USING (is_comparison_group)
GROUP BY 1, 2, total
ORDER BY 1, 2
;