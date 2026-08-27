SELECT date, AVG(CASE WHEN mode != 'period tracking' THEN 1::FLOAT ELSE 0 END)
FROM der.clue_plus_user_lifetimes
WHERE is_paid_subscribed
GROUP BY 1
ORDER BY 1
;