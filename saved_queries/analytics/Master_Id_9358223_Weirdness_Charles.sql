SELECT  COUNT(DISTINCT android_adid) AS count_android_adid,
        COUNT(DISTINCT sp_device_id) AS count_sp_device_id,
        COUNT(DISTINCT analytics_id) AS count_analytics_id
FROM der.master_id_device_map
WHERE master_id = 9358223
;

