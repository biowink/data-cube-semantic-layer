SELECT
    CASE
        WHEN cycle_phase = 'early follicular' THEN 'a. early follicular'
        WHEN cycle_phase = 'late follicular' THEN 'b. late follicular'
        WHEN cycle_phase = 'ovulation' THEN 'c. ovulation'
        WHEN cycle_phase = 'early luteal' THEN 'd. early luteal'
        WHEN cycle_phase = 'mid luteal' THEN 'e. mid luteal'
        WHEN cycle_phase = 'late luteal' THEN 'f. late luteal'
        WHEN user_last_birth_control_settings.type
                 IN ('combined_pill', 'vaginal_ring', 'hormonal_iud', 'implant', 'mini_pill', 'patch', 'shot')
            THEN 'g. hbc'
        ELSE 'h. missing period'
    END AS cycle_phase,
    COUNT(*) AS count_users,
    AVG(CASE WHEN goal_predict_period THEN 1.0 ELSE 0 END) AS goal_predict_period,
    AVG(CASE WHEN goal_understand_body THEN 1.0 ELSE 0 END) AS goal_understand_body,
    AVG(CASE WHEN goal_track_symptoms THEN 1.0 ELSE 0 END) AS goal_track_symptoms,
    AVG(CASE WHEN goal_gather_symptoms THEN 1.0 ELSE 0 END) AS goal_gather_symptoms,
    AVG(CASE WHEN period_frequency = 'regular' THEN 1.0 ELSE 0 END) AS period_frequency_regular,
    AVG(CASE WHEN period_frequency = 'irregular' THEN 1.0 ELSE 0 END) AS period_frequency_irregular,
    AVG(CASE WHEN period_frequency = 'dont know' THEN 1.0 ELSE 0 END) AS period_frequency_dont_know,
    AVG(CASE WHEN track_period THEN 1.0 ELSE 0 END) AS track_period,
    AVG(CASE WHEN track_pain THEN 1.0 ELSE 0 END) AS track_pain,
    AVG(CASE WHEN track_skin THEN 1.0 ELSE 0 END) AS track_skin,
    AVG(CASE WHEN track_sex_life THEN 1.0 ELSE 0 END) AS track_sex_life,
    AVG(CASE WHEN track_feelings THEN 1.0 ELSE 0 END) AS track_feelings,
    AVG(CASE WHEN track_energy THEN 1.0 ELSE 0 END) AS track_energy,
    AVG(count_tracking_categories_selected * 1.0) AS count_tracking_categories_selected,
    AVG(count_goals_selected * 1.0) AS count_goals_selected
FROM temp.cycle_phase_new_users
INNER JOIN user_metrics.user_onboarding_funnel USING (analytics_id)
LEFT JOIN user_metrics.user_last_birth_control_settings USING (analytics_id)
INNER JOIN user_metrics.user_goal_attributes USING (analytics_id)
LEFT JOIN der.profiles USING (analytics_id)
WHERE
    assign_onboarding_mode_mode = 'period tracking'
    AND DATE(finish_onboarding_ts) = DATE(account_created_at)
GROUP BY 1
ORDER BY 1
;
