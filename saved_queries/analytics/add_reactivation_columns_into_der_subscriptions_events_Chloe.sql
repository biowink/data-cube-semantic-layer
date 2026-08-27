ALTER TABLE der.subscriptions_events
ADD COLUMN reactivation BOOLEAN ENCODE ZSTD
default false;

ALTER TABLE der.subscriptions_events
ADD COLUMN days_to_reactivation BIGINT ENCODE ZSTD
default null;