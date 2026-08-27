select date, sum(installs) from temp.intermediate_adjust_campaign_performance
where network='Apple Search Ads'
and campaign like 'unknown (%' 
group by 1 order by 1