SELECT date,
       COUNT(*)
FROM der.clue_plus_user_lifetimes
WHERE date >= '2022-01-01' AND had_positive_pregnancy_test AND is_paid_subscribed
GROUP BY 1
ORDER BY 1
;