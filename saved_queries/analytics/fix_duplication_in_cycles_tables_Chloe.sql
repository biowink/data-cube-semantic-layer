BEGIN;

CREATE TABLE der.backend_cycles_new AS (
SELECT *,
    ROW_NUMBER() OVER (PARTITION BY analytics_id, cycle_batch_id, cycle_start, etl_execution_date
                      ORDER BY etl_updated_at DESC) as row_number
FROM der.backend_cycles
);

DELETE FROM der.backend_cycles_new
WHERE row_number != 1;

ALTER TABLE der.backend_cycles_new DROP COLUMN row_number;

ALTER TABLE der.backend_cycles RENAME TO backend_cycles_old;

ALTER TABLE der.backend_cycles_new RENAME TO backend_cycles;

CREATE TABLE temp.backend_cycles_old AS (
SELECT * FROM der.backend_cycles_old
);

DROP TABLE der.backend_cycles_old;

GRANT ALL ON der.backend_cycles TO etl;

COMMIT;

