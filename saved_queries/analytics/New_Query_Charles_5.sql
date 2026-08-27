SELECT
    currentmau.date,
    currentmau.platform,
    COUNT(DISTINCT currentmau.analytics_id) AS count_users,
    AVG(CASE WHEN nextmau.is_mau THEN 1.0 ELSE 0 END) AS mom_retention
FROM der.clue_plus_user_lifetimes currentmau
LEFT JOIN der.clue_plus_user_lifetimes nextmau ON currentmau.analytics_id = nextmau.analytics_id
    AND DATE_DIFF('day', currentmau.date, nextmau.date) = 30
WHERE
    DAY_OF_WEEK(DATE_ADD('day', 1, currentmau.date)) = 1
    AND currentmau.is_mau
    AND currentmau.is_clue_plus
    AND currentmau.mode = 'conceive'
    AND currentmau.country_name = 'United States'
    AND currentmau.language = 'English'
    AND currentmau.date BETWEEN DATE '2025-07-01' AND CURRENT_DATE - INTERVAL '31' DAY
    AND currentmau.platform IN ('ios', 'android')
GROUP BY 1, 2
ORDER BY 1, 2