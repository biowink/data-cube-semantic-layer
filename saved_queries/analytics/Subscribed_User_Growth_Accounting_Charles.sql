SELECT month,
       SUM(count_new_subscribers) AS count_new_subscribers,
       SUM(count_rejoiners) AS count_rejoiners,
       SUM(count_subscribed_active) AS count_subscribed_active,
       SUM(count_subscribed_inactive) AS count_subscribed_inactive,
       SUM(-count_churners) AS count_churners,
       SUM(-count_churned_free_active) AS count_churned_free_active,
       SUM(-count_churned_inactive) AS count_churned_inactive
FROM test.subscriber_growth_cohorts
GROUP BY 1
ORDER BY 1 DESC
;