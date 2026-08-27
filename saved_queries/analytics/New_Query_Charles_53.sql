SELECT date,
       NVL(platform, 'consent revokers') AS platform,
       count_dau::FLOAT/count_mau AS dau_mau,
       retained_mau::FLOAT/existing_mau AS mau_retention
FROM rep.active_user_trends
ORDER BY 2, 1 DESC
;