DROP TABLE der.ltv;

CREATE TABLE IF NOT EXISTS der.ltv (
    subscription_duration BIGINT ENCODE ZSTD,
    retention_curve BIGINT ENCODE ZSTD,
    renewal_rate DOUBLE PRECISION ENCODE ZSTD,
    renewal_periods BIGINT ENCODE ZSTD,
    gross_price DOUBLE PRECISION ENCODE ZSTD,
    predicted_rate DOUBLE PRECISION ENCODE ZSTD,
    revenue DOUBLE PRECISION ENCODE ZSTD,
    year_n BIGINT ENCODE ZSTD,
    net_revenue DOUBLE PRECISION ENCODE ZSTD,
    ltv DOUBLE PRECISION ENCODE ZSTD,
    created_execution_date TIMESTAMP WITH TIME ZONE ENCODE ZSTD
);

DROP TABLE der.ltv_per_country;

CREATE TABLE IF NOT EXISTS der.ltv_per_country (
    country VARCHAR ENCODE ZSTD,
    subscription_duration BIGINT ENCODE ZSTD,
    retention_curve BIGINT ENCODE ZSTD,
    renewal_rate DOUBLE PRECISION ENCODE ZSTD,
    renewal_periods BIGINT ENCODE ZSTD,
    gross_price DOUBLE PRECISION ENCODE ZSTD,
    predicted_rate DOUBLE PRECISION ENCODE ZSTD,
    revenue DOUBLE PRECISION ENCODE ZSTD,
    year_n BIGINT ENCODE ZSTD,
    net_revenue DOUBLE PRECISION ENCODE ZSTD,
    ltv DOUBLE PRECISION ENCODE ZSTD,
    created_execution_date TIMESTAMP WITH TIME ZONE ENCODE ZSTD
);
