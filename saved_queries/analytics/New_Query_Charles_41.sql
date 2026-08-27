select *
from temp.active_user_trends_accounts
WHERE date BETWEEN DATE('2024-09-01') AND DATE('2024-10-16')
ORDER BY date, platform
LIMIT 500
;