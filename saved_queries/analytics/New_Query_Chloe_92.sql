select 
    country_name, 
    SUM(clicks) as clicks,
    SUM(impressions) as impressions,
    SUM(cost) as cost
from der.adjust_deliverables
where campaign_name = 'NORDICS_ASA_Brand_Sep2019 (349761088)'
group by 1
order by 2 desc