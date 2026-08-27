-- status definitions: https://help.adjust.com/en/article/receive-consent-status?src=search_page

select 
    DATE_TRUNC('month', installed_at) as month,
    COUNT(CASE WHEN att_status = 0 THEN 1 ELSE NULL END) as att_status_0,
    COUNT(CASE WHEN att_status = 1 THEN 1 ELSE NULL END) as att_status_1,
    COUNT(CASE WHEN att_status = 2 THEN 1 ELSE NULL END) as att_status_2,
    COUNT(CASE WHEN att_status = 3 THEN 1 ELSE NULL END) as att_status_3,
    100*att_status_3::float / (att_status_2 + att_status_3) as att_opt_in_rate

from import.adjust

where 
    installed_at >= '2021-11-01'
    and os_name = 'ios'
    and att_status is not null

group by 1 order by 1