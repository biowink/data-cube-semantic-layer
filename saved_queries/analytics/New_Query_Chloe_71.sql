select 
    count(1),
    count(sp_device_id),
    count(country_name),
    count(platform)
from user_metrics.user_onboarding_funnel;
