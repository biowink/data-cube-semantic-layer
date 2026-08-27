SELECT 
    date,
    COUNT(*) AS count_rows
FROM der.clue_plus_user_lifetimes
WHERE date >= DATE '2026-01-01'
GROUP BY 1
ORDER BY 1 DESC
;