
SELECT SUM(tracking_points) AS total_historical_tracking_points FROM (
    SELECT
        COUNT(*) AS tracking_points
    FROM der.tracking
    UNION ALL
    SELECT
        COUNT(*) AS tracking_points
    FROM der.backend_tracking
    WHERE
        revision_type = 'measurements_tracked'
);