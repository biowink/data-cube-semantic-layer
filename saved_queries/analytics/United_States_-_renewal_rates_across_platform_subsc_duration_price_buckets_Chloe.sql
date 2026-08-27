select
    -- subscription_duration, 
    -- price_bucket, 
    -- platform,
    CONCAT(platform, CONCAT(CONCAT(' ', subscription_duration), CONCAT(' ', price_bucket))) as grp,
    
    retention_curve,
    renewal_rate
FROM der.ltv_copy