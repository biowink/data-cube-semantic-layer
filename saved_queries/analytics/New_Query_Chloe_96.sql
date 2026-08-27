select month_cohort 
from der.ccm
-- WHERE month_cohort >= DATE_TRUNC('month', CURRENT_DATE)::DATE - INTERVAL '13 months'
group by 1 order by 1