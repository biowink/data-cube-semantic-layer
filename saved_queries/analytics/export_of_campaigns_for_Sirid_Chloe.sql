select network_name, campaign_name, MIN(date) as min_date, MAX(date) as max_date
from import.adjust_deliverables
GROUP BY 1, 2
HAVING SUM(cost) > 0
ORDER BY 1, 2