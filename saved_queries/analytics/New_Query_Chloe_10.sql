WITH dupes AS (
    SELECT session_id, date(min(session_start)) as min_ss, date(max(session_start)) as max_ss
    FROM der.sessions
    WHERE DATE(session_start) BETWEEN DATE '2026-06-27' - INTERVAL '34' day
                                          AND DATE '2026-06-27'
    GROUP BY session_id
    HAVING COUNT(1) > 1
)
SELECT min_ss, max_ss, COUNT(1)
FROM dupes
group by 1,2 order by 1,2



select
    date_trunc('hour', root_tstamp) as dt,
    count(1)
from atomic_kinesis.com_snowplowanalytics_snowplow_client_session_1
where root_tstamp >= date '2026-06-26'
group by 1 order by 1;