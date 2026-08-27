WITH skad_data as (
SELECT 
    -- sk_ts,
    -- sk_payload,
    -- sk_version,
    -- sk_network_id,
    -- sk_campaign_id,
    -- sk_transaction_id,
    -- sk_app_id,
    -- sk_attribution_signature,
    -- sk_redownload,
    -- sk_source_app_id,
    -- sk_conversion_value,
    -- sk_invalid_signature,
    -- campaign_name,
    -- network_name
    *
FROM import.adjust
WHERE sk_ts > '2022-08-01'
)

select 
    sk_conversion_value,
    COUNT(sk_transaction_id) as records
from skad_data
group by 1 order by 1