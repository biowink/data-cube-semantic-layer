WITH experiment_ids AS (
    SELECT
        master_id AS master_id,
        derived_tstamp AS timestamp,
        JSON_EXTRACT_PATH_TEXT(event_properties, 'experiment_name', FALSE) AS experiment_id,
        JSON_EXTRACT_PATH_TEXT(event_properties, 'variant_id', FALSE) AS variation_id
    FROM der.events
    WHERE
        mobile_event_name = 'Enter Experiment'
        AND derived_tstamp >= '2023-04-17'
        AND experiment_id IN ('aatest_1','aatest_2','aatest_3',
                              'aatest_4','aatest_5')
), combined_assigment AS (
    SELECT
           master_id,
           MIN(CASE WHEN experiment_id = 'aatest_1' AND variation_id IN ('0', '1') THEN variation_id ELSE '9' END) || '-' ||
           MIN(CASE WHEN experiment_id = 'aatest_2' AND variation_id IN ('0', '1') THEN variation_id ELSE '9' END) || '-' ||
           MIN(CASE WHEN experiment_id = 'aatest_3' AND variation_id IN ('0', '1') THEN variation_id ELSE '9' END) || '-' ||
           MIN(CASE WHEN experiment_id = 'aatest_4' AND variation_id IN ('0', '1') THEN variation_id ELSE '9' END) || '-' ||
           MIN(CASE WHEN experiment_id = 'aatest_5' AND variation_id IN ('0', '1') THEN variation_id ELSE '9' END) 
               AS cross_test_assignment
    FROM experiment_ids
    GROUP BY 1
)
SELECT cross_test_assignment,
       COUNT(*) AS count_users
FROM combined_assigment
GROUP BY 1
ORDER BY 2 DESC
;