select
    date_trunc('hour', root_tstamp) as dt,
    count(1)
from atomic_kinesis.com_snowplowanalytics_snowplow_client_session_1
where root_tstamp >= date '2026-06-26'
group by 1 order by 1