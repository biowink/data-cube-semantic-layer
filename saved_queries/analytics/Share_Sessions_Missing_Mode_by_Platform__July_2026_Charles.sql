SELECT
    platform,
    LEAST(session_length_sec, 30) AS session_length_sec,
    AVG(CASE WHEN mode IS NULL THEN 1.0 ELSE 0 END) AS share_missing_mode,
    AVG(CASE WHEN product_tier IS NULL THEN 1.0 ELSE 0 END) AS share_missing_product_tier
FROM der.sessions
WHERE
    session_start BETWEEN DATE '2026-07-01' AND DATE '2026-08-01'
    AND platform IS NOT NULL
    AND session_length_sec IS NOT NULL
GROUP BY 1, 2
ORDER BY 1, 2
;