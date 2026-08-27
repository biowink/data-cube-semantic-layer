select * from der.ltv_copy 
where subscription_duration = 1
and retention_curve = 2
ORDER BY retention_curve, platform, price_bucket;
