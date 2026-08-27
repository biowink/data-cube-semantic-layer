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
    CASE
        WHEN account_created_dt <= period_end THEN '1. During Period'
        WHEN account_created_dt <= period_end + 3 THEN '2. After Period'
        WHEN account_created_dt <= ovulation_date THEN '3. Follicular Phase'
        WHEN account_created_dt <= cycle_end - 3 THEN '4. Luteal Phase'
        ELSE '5. Before Next Period'
    END AS phase,
        COUNT(*)::FLOAT / (
        SELECT COUNT(*)
        FROM first_cycles
    )
FROM first_cycles
GROUP BY 1
ORDER BY 1
;