SELECT FLOOR(c1.count_mode_tenure_days/7) * 7 AS weeks_in_mode,
       SPLIT_PART(c1.app_version, '.', 1)::INT >= 112 AS new_version,
       COUNT(DISTINCT c1.master_id || c1.date) AS cc_users,
       COUNT(DISTINCT CASE WHEN c2.mode = 'period tracking' THEN c1.master_id || c1.date END) AS leaving_users,
       leaving_users::FLOAT/cc_users
FROM der.clue_plus_user_lifetimes c1
LEFT JOIN der.clue_plus_user_lifetimes c2 USING (master_id)
WHERE c1.date + 1 = c2.date
AND c1.is_subscribed
AND c1.mode = 'conceive'
AND c1.platform = 'ios'
AND c1.date >= '2023-04-01'
AND c1.count_mode_tenure_days < 210
AND c2.is_subscribed
AND SPLIT_PART(c1.app_version, '.', 1)::INT > 100
AND c2.is_dau
GROUP BY 1, 2
ORDER BY 1, 2
;