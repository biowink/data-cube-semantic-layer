CREATE SCHEMA IF NOT EXISTS {{schema}};

CREATE TABLE {{schema}}.d7_to_d0_ccm (
    prediction_created_date TIMESTAMP WITH TIME ZONE ENCODE ZSTD,
    subscription_duration BIGINT ENCODE ZSTD,
    platform VARCHAR(50) ENCODE ZSTD,
    market VARCHAR(50) ENCODE ZSTD,
    d0_conversion_count BIGINT ENCODE ZSTD,
    d7_conversion_count BIGINT ENCODE ZSTD,
    d7_to_d0_ccm DOUBLE PRECISION ENCODE ZSTD
);

INSERT INTO {{schema}}.d7_to_d0_ccm
(select * FROM der.d7_to_d0_ccm);

CREATE TABLE {{schema}}.d360_to_d7_ccm (
    prediction_created_date TIMESTAMP WITH TIME ZONE ENCODE ZSTD,
    subscription_duration BIGINT ENCODE ZSTD,
    platform VARCHAR(50) ENCODE ZSTD,
    market VARCHAR(50) ENCODE ZSTD,
    d7_conversion_count BIGINT ENCODE ZSTD,
    d360_conversion_count BIGINT ENCODE ZSTD,
    d360_to_d7_ccm DOUBLE PRECISION ENCODE ZSTD
);

INSERT INTO {{schema}}.d360_to_d7_ccm
(select * FROM der.d360_to_d7_ccm);

CREATE TABLE {{schema}}.ltv (
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
    is_total_ltv BOOLEAN ENCODE ZSTD,
    created_execution_date TIMESTAMP WITH TIME ZONE ENCODE ZSTD
);

INSERT INTO {{schema}}.ltv
(select * FROM der.ltv);

CREATE TABLE {{schema}}.segmented_ltv (
    country VARCHAR ENCODE ZSTD,
    market VARCHAR ENCODE ZSTD,
    subscription_duration BIGINT ENCODE ZSTD,
    platform VARCHAR(50) ENCODE ZSTD,
    is_in_intro_offer_period BOOLEAN ENCODE ZSTD,
    retention_curve BIGINT ENCODE ZSTD,
    sample_weight BIGINT ENCODE ZSTD,
    renewal_rate DOUBLE PRECISION ENCODE ZSTD,
    renewal_periods BIGINT ENCODE ZSTD,
    gross_price DOUBLE PRECISION ENCODE ZSTD,
    gross_full_price DOUBLE PRECISION ENCODE ZSTD,
    predicted_rate DOUBLE PRECISION ENCODE ZSTD,
    revenue DOUBLE PRECISION ENCODE ZSTD,
    year_n BIGINT ENCODE ZSTD,
    net_revenue DOUBLE PRECISION ENCODE ZSTD,
    ltv DOUBLE PRECISION ENCODE ZSTD,
    is_total_ltv BOOLEAN ENCODE ZSTD,
    created_execution_date TIMESTAMP WITH TIME ZONE ENCODE ZSTD
);

INSERT INTO {{schema}}.segmented_ltv
(select * FROM der.segmented_ltv);

GRANT ALL PRIVILEGES ON SCHEMA {{schema}}
TO etl;

GRANT SELECT ON {{schema}}.d7_to_d0_ccm, {{schema}}.d360_to_d7_ccm, 
                {{schema}}.ltv, {{schema}}.segmented_ltv
TO GROUP reader;