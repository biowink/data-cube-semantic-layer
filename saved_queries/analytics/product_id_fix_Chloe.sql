select product_id, 
    CASE WHEN product_id LIKE '%promo%' THEN RIGHT(REPLACE(product_id, 'v2', ''), 2) END AS discount_rate
from import.subscriptions_events subev
group by 1 order by 1