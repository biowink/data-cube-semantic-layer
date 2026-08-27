select 
    count(CASE WHEN account_created_at < first_seen THEN master_id ELSE NULL END)::float
        / count(master_id) AS share_with_backwards_dates,
        
    avg(CASE WHEN account_created_at < first_seen THEN 1.0 ELSE 0.0 END) AS share_with_backwards_dates2
    
from der.sp_users;