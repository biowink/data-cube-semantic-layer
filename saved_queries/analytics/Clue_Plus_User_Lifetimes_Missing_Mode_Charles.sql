SELECT
    DATE_TRUNC('month',date) AS month,
    mode IS NULL AS missing_mode,
    COUNT(*) AS count_users
FROM der.clue_plus_user_lifetimes
GROUP BY 1, 2
ORDER BY 1, 2
;