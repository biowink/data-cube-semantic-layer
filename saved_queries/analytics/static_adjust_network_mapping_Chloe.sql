DROP TABLE static.adjust_network_mapping;

CREATE TABLE static.adjust_network_mapping AS (
SELECT
    os_name AS platform,
    network,
    CASE WHEN network IN ('Facebook (Ad Spend)', 'Facebook (SKAdNetwork)', 'Facebook Installs',
                          'Instagram Installs', 'Facebook Messenger Installs', 'Off-Facebook Installs')
         THEN 'Facebook'
         WHEN network IN ('Snapchat Installs', 'Snapchat Audience Network', 'Snapchat (Ad Spend)')
         THEN 'Snapchat'
         WHEN network IN ('TikTok - Android', 'TikTok', 'TikTok for Business (Ad Spend)', 'TikTok for Business (SKAdNetwork)', 'TikTok (iOS - Mobvista)')
         THEN 'TikTok'
         WHEN network IN ('Google Ads (Ad Spend)', 'Google Ads (SKAdNetwork)', 'Google Ads (unknown)')
         THEN 'Google Ads ACI'
         ELSE network END
    AS clean_network,
    CASE WHEN clean_network in ('Facebook', 'TikTok')
         AND platform = 'ios'
         THEN TRUE
         ELSE FALSE END
    AS self_attributing_network
FROM import.adjust_campaign_performance
WHERE network NOT IN ('Jesse Pinho''s Dev Sandbox', 'test-jane', 'test tracker', 'Imported Devices')
  AND os_name IN ('android', 'ios')
GROUP BY 1, 2
ORDER BY 1, 2
);

GRANT SELECT ON static.adjust_network_mapping
TO GROUP reader;

SELECT * FROM static.adjust_network_mapping