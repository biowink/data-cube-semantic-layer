SELECT LEAST(GREATEST(cycle_length, 20), 40) AS cycle_length,
       COUNT(DISTINCT users.analytics_id) AS count_users,
       COUNT(DISTINCT sessions.analytics_id) * 1.0/COUNT(DISTINCT users.analytics_id) AS share_retained
FROM der.users
INNER JOIN user_metrics.user_first_session_attributes ON users.analytics_id = user_first_session_attributes.analytics_id
INNER JOIN der.profiles ON users.analytics_id = profiles.analytics_id
LEFT JOIN der.sessions ON users.analytics_id = sessions.analytics_id
    AND DATE_DIFF('day', account_created_at, session_start) BETWEEN 1 AND 7
    AND session_start BETWEEN DATE('2022-06-01') AND DATE('2022-11-01')
WHERE account_created_at BETWEEN DATE('2022-06-01') AND DATE('2022-10-01')
    AND user_first_session_attributes.platform = 'ios'
    AND cycle_length IS NOT NULL
GROUP BY 1
ORDER BY 1
;