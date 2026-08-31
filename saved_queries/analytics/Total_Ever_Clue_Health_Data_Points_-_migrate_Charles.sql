WITH individual_data_point_inputs AS (
-- Count of non-NULL profile health data points users enter in onboarding, some are no longer even in the app
SELECT
    'User Profile Data Points' AS metric,
    COUNT(weight) + COUNT(height) + COUNT(birthday) + COUNT(cycle_length) AS value
FROM der.profiles
GROUP BY 1
UNION ALL
-- Count of health conditions that users have input, but unavailable for most users and all older inactive accounts
SELECT
    'User Health Conditions' AS metric,
    COUNT(*) AS value
FROM der.backend_medical_records_long
GROUP BY 1
UNION ALL
-- Count of cycle logs imported from Legacy or created during Rebirth, multiplied by six to represent the six
-- different data points of cycle start, cycle length, period length, ovulation date, fertile window start,
-- and fertile window length
SELECT
    'Cycle Data Points' AS metric,
    COUNT(*) * 6 AS value
FROM der.backend_cycles
GROUP BY 1
UNION ALL
-- Count of tracking points created in the Legacy tracking system, this never should in theory never update
SELECT
    'Legacy Tracking Points' AS value,
    COUNT(*) AS metric
FROM der.tracking
UNION ALL
-- Count of Rebirth tracking points created, only counting those tracked by users in Rebirth and not imported over
SELECT
    'Rebirth Tracking Points' AS value,
    COUNT(*) AS metric
FROM der.backend_tracking
WHERE
    revision_type = 'measurements_tracked'
UNION ALL
-- Count of birth control methods input by users in Legacy
SELECT
    'Legacy Birth Control' AS metric,
    COUNT(*) AS value
FROM der.birth_control
GROUP BY 1
UNION ALL
-- Count of birth control methods input by users in Rebirth
SELECT
    'Rebirth Birth Control' AS metric,
    COUNT(*) AS value
FROM der.backend_birth_control_settings
GROUP BY 1
)
SELECT
    metric,
    value
FROM individual_data_point_inputs
UNION ALL
SELECT
    'TOTAL HEALTH DATA POINTS' AS metric,
    SUM(value) AS value
FROM individual_data_point_inputs
GROUP BY 1
ORDER BY 2 DESC
;