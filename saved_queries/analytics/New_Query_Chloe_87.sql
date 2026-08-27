select created_execution_date, ltv
FROM der.ltv
where subscription_duration = 1 and retention_curve = 35
order by created_execution_date;
