WITH first_cycles AS (
    SELECT
        backend_cycles.*,
        account_created_at::DATE AS account_created_dt
    FROM der.backend_cycles
    INNER JOIN der.users
            USING (analytics_id)
    WHERE
        account_created_at BETWEEN '2023-04-01' AND '2023-07-31'
        AND account_created_at::DATE BETWEEN cycle_start AND cycle_end
        AND cycle_length <= 45
)
SELECT
    FLOOR(DATEDIFF('day', cycle_start, account_created_dt)::FLOAT / cycle_length * 10) AS cycle_decile,
        COUNT(*)::FLOAT / (
        SELECT COUNT(*)
        FROM first_cycles
    )
FROM first_cycles
GROUP BY 1
ORDER BY 1 DESC
;