SELECT month_recognized,
       subscription_duration,
       COUNT(*) AS count,
       AVG(new_mrr) AS avg_mrr,
       SUM(new_mrr) AS new_mrr
FROM rep.mrr_metrics
WHERE month_recognized < DATE_TRUNC('month', CURRENT_DATE) AND new_mrr > 0
GROUP BY 1, 2
ORDER BY 1 DESC, 2
;