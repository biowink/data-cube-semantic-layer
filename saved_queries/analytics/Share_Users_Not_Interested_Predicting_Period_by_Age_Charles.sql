SELECT GREATEST(DATE_DIFF('year', birthday, DATE '2025-01-01'), 12) AS age,
       COUNT(*) AS count,
       AVG(CASE WHEN NOT goal_predict_period THEN 1.0 ELSE 0 END) AS share_not_interested_in_predicting_period
FROM user_metrics.user_goal_attributes
INNER JOIN der.profiles USING (analytics_id)
WHERE birthday IS NOT NULL AND NOT goal_none_of_the_above
GROUP BY 1
HAVING COUNT(*) > 5000
ORDER BY 1
