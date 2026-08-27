------------------ der.ltv
alter table der.ltv
add column created_execution_date_copy TIMESTAMP WITH TIME ZONE ENCODE ZSTD
DEFAULT NULL;

update der.ltv
set created_execution_date_copy = created_execution_date;

alter table der.ltv
drop column created_execution_date;

alter table der.ltv
rename column created_execution_date_copy to created_execution_date;

update der.ltv
set is_total_ltv = false;

update der.ltv
set is_total_ltv = true
where subscription_duration = 12 AND retention_curve = 24;

update der.ltv
set is_total_ltv = true
where subscription_duration = 1 AND retention_curve = 35;

update der.ltv
set is_total_ltv = true
where subscription_duration = 6 AND retention_curve = 30;


------------------ der.segmented_ltv
alter table der.segmented_ltv
add column created_execution_date_copy TIMESTAMP WITH TIME ZONE ENCODE ZSTD
DEFAULT NULL;

update der.segmented_ltv
set created_execution_date_copy = created_execution_date;

alter table der.segmented_ltv
drop column created_execution_date;

alter table der.segmented_ltv
rename column created_execution_date_copy to created_execution_date;

update der.segmented_ltv
set is_total_ltv = false;

update der.segmented_ltv
set is_total_ltv = true
where subscription_duration = 12 AND retention_curve = 24;

update der.segmented_ltv
set is_total_ltv = true
where subscription_duration = 1 AND retention_curve = 35;

update der.segmented_ltv
set is_total_ltv = true
where subscription_duration = 6 AND retention_curve = 30;
