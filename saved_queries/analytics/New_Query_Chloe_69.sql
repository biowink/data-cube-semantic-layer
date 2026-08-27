select
    count(users.analytics_id) as users,
    count(profiles.analytics_id) as profiles,
    profiles::float/users as share
from der.users
left join der.profiles using (analytics_id)

