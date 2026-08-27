CREATE TABLE intermediate.pivoted_data (
    computed_cycle_type string,
    analytics_id string,
    event_id string,
    collector_tstamp timestamp,
    mode string,
    cycle_start_date timestamp,
    cycle_end_date timestamp,
    period_start_date timestamp,
    period_end_date timestamp,
    period_phase_data string,
    ovulation_start_date timestamp,
    ovulation_end_date timestamp,
    fertile_start_date timestamp,
    fertile_end_date timestamp,
    pms_start_date timestamp,
    pms_end_date timestamp,
    conception_start_date timestamp,
    conception_end_date timestamp,
    conception_phase_data string
)
LOCATION 's3://clue-data-prod-athena-iceberg-storage/iceberg/intermediate/pivoted_data'
TBLPROPERTIES (
  'table_type'='iceberg'
);

DELETE FROM intermediate.pivoted_data;

INSERT INTO intermediate.pivoted_data (
    computed_cycle_type,
    analytics_id,
    event_id,
    collector_tstamp,
    mode,
    cycle_start_date,
    cycle_end_date,
    period_start_date,
    period_end_date,
    period_phase_data,
    ovulation_start_date,
    ovulation_end_date,
    fertile_start_date,
    fertile_end_date,
    pms_start_date,
    pms_end_date,
    conception_start_date,
    conception_end_date,
    conception_phase_data
)
SELECT
    computed_cycle_type,
    analytics_id,
    event_id,
    collector_tstamp,
    mode,
    cycle_start_date,
    cycle_end_date,
    
    MAX(CASE WHEN phase = 'periodPhase' THEN phase_start_date ELSE NULL END) AS period_start_date,
    MAX(CASE WHEN phase = 'periodPhase' THEN phase_end_date ELSE NULL END) AS period_end_date,
    MAX(CASE WHEN phase = 'periodPhase' THEN phase_data ELSE NULL END) AS period_phase_data,
    
    MAX(CASE WHEN phase = 'ovulationPhase' THEN phase_start_date ELSE NULL END) AS ovulation_start_date,
    MAX(CASE WHEN phase = 'ovulationPhase' THEN phase_end_date ELSE NULL END) AS ovulation_end_date,
    
    MAX(CASE WHEN phase = 'fertilePhase' THEN phase_start_date ELSE NULL END) AS fertile_start_date,
    MAX(CASE WHEN phase = 'fertilePhase' THEN phase_end_date ELSE NULL END) AS fertile_end_date,
    
    MAX(CASE WHEN phase = 'pmsPhase' THEN phase_start_date ELSE NULL END) AS pms_start_date,
    MAX(CASE WHEN phase = 'pmsPhase' THEN phase_end_date ELSE NULL END) AS pms_end_date,
    
    MAX(CASE WHEN phase = 'conceptionPhase' THEN phase_start_date ELSE NULL END) AS conception_start_date,
    MAX(CASE WHEN phase = 'conceptionPhase' THEN phase_end_date ELSE NULL END) AS conception_end_date,
    MAX(CASE WHEN phase = 'conceptionPhase' THEN phase_data ELSE NULL END) AS conception_phase_data
    
FROM import.backend_computed_cycles_updated
GROUP BY computed_cycle_type,
    analytics_id,
    event_id,
    collector_tstamp,
    mode,
    cycle_start_date,
    cycle_end_date
;









