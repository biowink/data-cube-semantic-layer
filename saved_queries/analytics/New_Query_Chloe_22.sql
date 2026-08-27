with tab as (SELECT
    CASE
            WHEN adjust_attribution.network IS NULL THEN 'no attribution'
            ELSE 'attribution'
          END
     AS "source_type",
        (DATE_FORMAT("users"."account_created_at", '%Y-%m-%d')) AS "account_created_date",
    COUNT(DISTINCT users.analytics_id ) AS "user_count"
FROM
    "der"."users" AS "users"
    LEFT JOIN "user_metrics"."adjust_attribution" AS "adjust_attribution" ON "users"."analytics_id" = "adjust_attribution"."analytics_id"
WHERE ((( "users"."account_created_at" ) >= ((DATE_ADD('day', -30, CAST(CAST(DATE_TRUNC('DAY', NOW()) AS DATE) AS TIMESTAMP)))) AND ( "users"."account_created_at" ) < ((DATE_ADD('day', 30, DATE_ADD('day', -30, CAST(CAST(DATE_TRUNC('DAY', NOW()) AS DATE) AS TIMESTAMP)))))))
GROUP BY
    1,
    2
)

select
    account_created_date,
    100*cast(sum(case when source_type = 'no attribution' then user_count else null end) as double) / sum(user_count) as share_of_users_without_attribution
from tab
group by 1 order by 1