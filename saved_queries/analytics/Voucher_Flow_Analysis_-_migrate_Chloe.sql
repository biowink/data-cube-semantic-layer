with filtered_session_ids as (
    select session_id 
    from der.web_events
    where derived_tstamp >= date '2025-03-01' and event_name = 'page_view'
    group by 1
    having max(case when derived_page_title = '/redeem' then 1 else 0 end) = 1
      and max(case when derived_page_title = '/clue-plus' then 1 else 0 end) = 1 
),

filtered_sessions as (
    select *
    from der.web_events
    join filtered_session_ids using(session_id)
    where event_name = 'page_view' and derived_page_title not in ('/oauthcallback/google/login', '/oauthcallback/apple/login')
),

second_filter as (
    select
        sessions_one.session_id
    from filtered_sessions as sessions_one
    join filtered_sessions as sessions_two on (sessions_one.session_id = sessions_two.session_id)
    where sessions_one.derived_page_title = '/redeem' 
        and sessions_two.derived_page_title = '/clue-plus'
        and sessions_two.derived_tstamp between sessions_one.derived_tstamp and date_add('minute', 3, sessions_one.derived_tstamp)
    group by 1
),

ordered_sessions as (
    select
        filtered_sessions.session_id,
        derived_tstamp,
        derived_page_title,
        ROW_NUMBER() OVER (PARTITION BY filtered_sessions.session_id ORDER BY derived_tstamp rows between unbounded preceding and unbounded following) 
          as page_number
    from filtered_sessions
    join second_filter on (filtered_sessions.session_id = second_filter.session_id)
),

-- last_page as (
--     select session_id, max(page_number) as last_page
--     from ordered_sessions
--     group by 1
-- )

-- select last_page, count(1) from last_page group by 1 order by 1

pivoted_data as (
          select
              session_id,
              count(case when derived_page_title = '/redeem' then 1 else null end) as times_reached_redeem,
              min(case when derived_page_title = '/redeem' then page_number else null end) as first_reached_redeem,
              min(case when derived_page_title = '/redeem' then page_number else null end) as last_reached_redeem,
              max(case when page_number = 1 then derived_page_title else null end) as page_1,
              max(case when page_number = 2 then derived_page_title else null end) as page_2,
              max(case when page_number = 3 then derived_page_title else null end) as page_3,
              max(case when page_number = 4 then derived_page_title else null end) as page_4,
              max(case when page_number = 5 then derived_page_title else null end) as page_5,
              max(case when page_number = 6 then derived_page_title else null end) as page_6,
              max(case when page_number = 7 then derived_page_title else null end) as page_7,
              max(case when page_number = 8 then derived_page_title else null end) as page_8,
              max(case when page_number = 9 then derived_page_title else null end) as page_9,
              max(case when page_number = 10 then derived_page_title else null end) as page_10,
              max(case when page_number = 11 then derived_page_title else null end) as page_11,
              max(case when page_number = 12 then derived_page_title else null end) as page_12,
              max(case when page_number = 13 then derived_page_title else null end) as page_13,
              max(case when page_number = 14 then derived_page_title else null end) as page_14,
              max(case when page_number = 15 then derived_page_title else null end) as page_15,
              max(case when page_number = 16 then derived_page_title else null end) as page_16,
              max(case when page_number = 17 then derived_page_title else null end) as page_17,
              max(case when page_number = 18 then derived_page_title else null end) as page_18,
              max(case when page_number = 19 then derived_page_title else null end) as page_19,
              max(case when page_number = 20 then derived_page_title else null end) as page_20
          from ordered_sessions
          group by 1
      )

      select
        --   page_1, page_2, page_3, page_4, page_5, 
        --   page_6, page_7, page_8, page_9, page_10, 
        --   page_11, page_12, page_13, page_14, page_15, 
        --   page_16, page_17, page_18, page_19, page_20, 
            -- page_1, page_2, 
            case when last_reached_redeem > 6 then 1 else 0 end as reached_after_6_page_views,
          count(session_id) as sessions
      from pivoted_data
      group by 1
    --   group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20
      order by count(session_id) desc
      ;;