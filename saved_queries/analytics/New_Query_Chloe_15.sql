select * from temp.intermediate_backend_campaign_performance
where network = 'Organic' 
and date = date '2026-05-01'
order by platform, country_code