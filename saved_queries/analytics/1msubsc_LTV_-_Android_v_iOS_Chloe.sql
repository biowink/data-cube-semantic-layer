select retention_curve,
    MAX(CASE WHEN platform = 'ANDROID' THEN renewal_rate ELSE NULL END) as android_renewal_rate,
    MAX(CASE WHEN platform = 'IOS' THEN renewal_rate ELSE NULL END) as ios_renewal_rate,
    MAX(CASE WHEN platform = 'ANDROID' THEN ltv ELSE NULL END) as android_ltv,
    MAX(CASE WHEN platform = 'IOS' THEN ltv ELSE NULL END) as ios_ltv
from der.ltv_copy
where subscription_duration = 1
group by 1 order by 1