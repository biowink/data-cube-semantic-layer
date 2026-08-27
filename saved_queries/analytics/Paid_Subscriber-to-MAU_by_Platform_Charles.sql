SELECT month,
    ios_paying/SUM(count_mau * share_ios) AS ios_subscriber_to_mau,
    android_paying/SUM(count_mau * (1 -share_ios)) AS android_subscriber_to_mau
FROM rep.mau_static
LEFT JOIN (SELECT month, SUM(CASE WHEN platform = 'ios' THEN count_mau * 1.0 END)/ SUM(CASE WHEN platform IN ('ios', 'android') THEN count_mau * 1.0 END) AS share_ios
           FROM rep.mau_static GROUP BY 1) AS share_total USING (month)
LEFT JOIN (SELECT month,
    SUM(CASE WHEN platform = 'ios' THEN user_count END) AS ios_paying,
    SUM(CASE WHEN platform = 'android' THEN user_count END) AS android_paying
FROM rep.clue_plus_users_static
GROUP BY 1) AS paying_users USING (month)
WHERE month >= DATE('2021-01-01')
GROUP BY 1, ios_paying, android_paying
ORDER BY 1 DESC
LIMIT 500
;