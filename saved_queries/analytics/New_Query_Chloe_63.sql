select 
    "segments.date",
    "campaign.name",
    "campaign_budget.amount_micros"/1000000.0 as campaign_budget_amount,
    "segments.ad_network_type",
    sum("metrics.cost_micros")/1000000.0 as cost,
    sum("metrics.impressions") as impressions,
    sum("metrics.clicks") as clicks,
    sum("metrics.conversions") as conversions
from airbyte.google_ads_campaign
where "campaign.name" = 'English_GoogleAds_Sigup_Search_ZA_1stTest'
group by 1, 2, 3, 4
order by 1, 2, 3, 4