SELECT
    cycle_phase_new_users.platform,
    CASE
        WHEN cycle_phase = 'early follicular' THEN 'a. early follicular'
        WHEN cycle_phase = 'late follicular' THEN 'b. late follicular'
        WHEN cycle_phase = 'ovulation' THEN 'c. ovulation'
        WHEN cycle_phase = 'early luteal' THEN 'd. early luteal'
        WHEN cycle_phase = 'mid luteal' THEN 'e. mid luteal'
        WHEN cycle_phase = 'late luteal' THEN 'f. late luteal'
        ELSE 'h. missing period'
    END AS cycle_phase
FROM temp.cycle_phase_new_users
GROUP BY 1, 2
ORDER BY 1, 2
;