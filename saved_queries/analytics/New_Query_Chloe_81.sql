select 
    case when SPLIT_PART(last_app_version,'.', 1)::INT >= 100 THEN 1 else 0 end AS seen_on_rebirth,
    case when SPLIT_PART(first_app_version,'.', 1)::INT >= 100 THEN 1 else 0 end AS started_on_rebirth,
    count(master_id) as users,
    count(CASE WHEN account_created_at < first_seen THEN master_id ELSE NULL END)::float
        / count(master_id) AS share_with_backwards_dates
        
    
from der.sp_users

WHERE first_platform = 'ios'
group by 1, 2
order by 1, 2