select date_trunc('month',tstamp) as dt, count(1) from der.braze_message_sends

group by 1 order by 1