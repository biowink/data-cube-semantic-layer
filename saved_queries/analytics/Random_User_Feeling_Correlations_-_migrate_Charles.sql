WITH random_user AS (
    SELECT analytics_id, RANDOM() AS random_number FROM temp.feelings_subscribers_cycles_12 ORDER BY random_number LIMIT 1
),
    combinations AS (
    SELECT
        analytics_id,
        feeling_type,
        category,
        type,
        COUNT(*) AS count_cooccurrences
    FROM random_user
    INNER JOIN temp.feelings_subscribers_correlates_12
            USING (analytics_id)
    WHERE
        category NOT IN ('period', 'weight', 'tests', 'sleep_duration', 'tags', 'notes', 'collection_method', 'bbt',
                          'birth_control_implant', 'birth_control_patch', 'birth_control_pill', 'birth_control_ring', 'birth_control_shot',
                          'appointments', 'medication', 'supplements', 'feelings')
    GROUP BY 1, 2, 3, 4
),
    top_combinations AS (
        SELECT
            analytics_id,
            feeling_type,
            MAX(count_cooccurrences) AS highest_frequency
        FROM combinations
        GROUP BY 1, 2
    )
SELECT analytics_id,
       feeling_type,
       category,
       type,
       count_cooccurrences
FROM top_combinations
INNER JOIN combinations USING (analytics_id, feeling_type)
WHERE highest_frequency = count_cooccurrences
ORDER BY 1, 5 DESC, 2
;