SELECT
    gross_sales_euro
FROM
    "der"."subscriptions_events" AS "subscriptions_events"
WHERE ((( subscriptions_events.backend_created_at::TIMESTAMP  ) >= ((DATEADD(month,-1, DATE_TRUNC('month', DATE_TRUNC('day',GETDATE())) ))) AND ( subscriptions_events.backend_created_at::TIMESTAMP  ) < ((DATEADD(month,1, DATEADD(month,-1, DATE_TRUNC('month', DATE_TRUNC('day',GETDATE())) ) ))))) AND "country" IN ('Australia', 'Austria', 'Belgium', 'Canada', 'Denmark', 'Finland', 'France', 'Germany', 'Ireland', 'Italy', 'Japan', 'Luxembourg', 'Netherlands', 'New Zealand', 'Norway', 'Portugal', 'Spain', 'Sweden', 'Switzerland', 'United Kingdom') AND "subscription_duration" = 1 
AND subscription_type = 'Subscription Renewed'
;