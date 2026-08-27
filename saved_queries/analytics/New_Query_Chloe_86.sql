select market, subscription_count, count(1)
from intermediate.promo_share
join static.market_mapping using(country)
group by 1, 2 order by 1, 2