select *
from der.sessions s 
left join "static".market_mapping mm on cast(s.country_name as varchar) = cast(mm.country as varchar)
limit 100