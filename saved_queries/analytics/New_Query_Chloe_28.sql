select date_trunc('day', install_time), count(1) 
from user_metrics.adjust_attribution 
where raw_network = 'Unattributed'
  and install_time >= current_date - interval '90' day
group by 1 order by 1