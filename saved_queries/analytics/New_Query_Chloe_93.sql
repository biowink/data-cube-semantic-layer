select target_country, network_name
FROM static.adjust_campaign_countries
group by 1, 2