SELECT platform,
       CASE WHEN market != 'Rest of World' 
            THEN 'StraMa'
            ELSE market
        END AS strama,
       json_extract_path_text(event_properties, 'Authentication Method') AS authentication_method,
       COUNT(*) AS count,
       AVG(CASE WHEN account_is_verified IS TRUE THEN 1::FLOAT ELSE 0 END) AS share_verified
FROM der.events
INNER JOIN der.sp_users USING (master_id)
INNER JOIN static.market_mapping
    ON sp_users.first_country_name = market_mapping.country
WHERE mobile_event_name = 'Did Create Account'
    AND major_app_version > 100
    AND derived_tstamp >= CURRENT_DATE - 30
    AND first_seen BETWEEN CURRENT_DATE - 30 AND CURRENT_DATE - 7
    AND authentication_method = 'email'
GROUP BY 1, 2, 3 
ORDER BY 1, 2, 3
;