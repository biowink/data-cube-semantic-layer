WITH minimum_cc_time AS (
    -- Filters to users who have been in Clue Conceive mode for over days; these are the only users for whom we would
    -- consider a resulting pregnancy as properly attributed to Conceive mode
    SELECT analytics_id,
           COUNT(*) AS count_days_in_cc
    FROM der.clue_plus_user_lifetimes
    WHERE mode = 'conceive'
    GROUP BY 1
    HAVING COUNT(*) > 5
),
    cc_running_counts AS (
    -- This creates a column running_cc_switches which divides the users lifecycle into periods based on how many times
    -- they have cumulatively switched out of Conceive mode
    SELECT
        analytics_id,
        date,
        mode,
        mode_previous_day,
        LEAD(mode) OVER (PARTITION BY analytics_id ORDER BY date ASC) AS mode_next_day,
        had_positive_pregnancy_test,
        SUM(CASE WHEN mode != 'conceive' AND mode_previous_day = 'conceive' THEN 1 ELSE 0 END)
            OVER (PARTITION BY analytics_id ORDER BY date ASC
                    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_cc_switches
    FROM
        der.clue_plus_user_lifetimes
    INNER JOIN
        minimum_cc_time USING (analytics_id)
),
    cc_block_refactoring AS (
    -- This then counts how many days users have been inside of Conceive mode for each period of time they use the mode,
    -- it is reset each time they switch out and the counter reverts to 0 (because we partition by running_cc_switches)
    SELECT
        analytics_id,
        date,
        mode,
        mode_previous_day,
        mode_next_day,
        had_positive_pregnancy_test,
        running_cc_switches,
        SUM(CASE WHEN mode = 'conceive' THEN 1 ELSE 0 END)
            OVER (PARTITION BY analytics_id, running_cc_switches ORDER BY date ASC
                    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_cc_block_count
    FROM cc_running_counts
),
    next_cycle_time_windows AS (
    -- For users who switch into a mode other than pregnancy, we see need to get the date which their current cycle
    -- ends, as this also enters into the attribution logic
    SELECT
        analytics_id,
        running_cc_switches,
        date AS switch_date,
        MIN(cycle_end) AS current_cycle_end
    FROM cc_block_refactoring
    INNER JOIN der.backend_cycles USING (analytics_id)
    WHERE
        mode= 'conceive'
        AND mode_next_day NOT IN ('conceive', 'pregnancy')
        AND running_cc_block_count > 5
        AND cycle_end > date
    GROUP BY 1, 2, 3
),
    pregnancy_criteria_users AS (
    -- This top query pulls users who have been in conceive for over five days and either track a positive pregnancy
    -- test or switch the next day into Pregnancy mode
    SELECT
        date,
        cc_block_refactoring.analytics_id,
        cc_block_refactoring.running_cc_switches,
        cc_block_refactoring.analytics_id || CAST(cc_block_refactoring.running_cc_switches AS VARCHAR) AS user_cc_period_id
    FROM
        cc_block_refactoring
    WHERE
        cc_block_refactoring.running_cc_block_count > 5
        AND cc_block_refactoring.mode = 'conceive'
        AND (cc_block_refactoring.had_positive_pregnancy_test OR cc_block_refactoring.mode_next_day = 'pregnancy')
    UNION ALL
    -- This bottom query pulls users who switch into Pregnancy mode or have a positive pregnancy test in the dates
    -- that correspond to the remaining portion of the last cycle they were in Conceive mode for
    SELECT
        date,
        next_cycle_time_windows.analytics_id,
        next_cycle_time_windows.running_cc_switches,
        next_cycle_time_windows.analytics_id || CAST(next_cycle_time_windows.running_cc_switches AS VARCHAR) AS user_cc_period_id
    FROM next_cycle_time_windows
    INNER JOIN der.clue_plus_user_lifetimes ON next_cycle_time_windows.analytics_id = clue_plus_user_lifetimes.analytics_id
    WHERE date BETWEEN switch_date AND current_cycle_end
        AND (mode = 'pregnancy' OR had_positive_pregnancy_test)
)
    -- The top counts how many of the contiguous periods of Clue Conceive mode usage (more than five days long) resulted
    -- in a "pregnancy" matching the above criteria and the top counts how many distinct users/accounts have such a
    -- "pregnancy" associated with one of the periods
SELECT COUNT(DISTINCT user_cc_period_id) AS count_potential_pregnancies,
       COUNT(DISTINCT analytics_id) AS count_potential_pregnancies_users
FROM pregnancy_criteria_users
;