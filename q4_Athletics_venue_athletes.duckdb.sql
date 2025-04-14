-- 筛选出举办过田径比赛的场馆
with target_venue as(
        select distinct v.venue
        from venues v
        join results r
        on r.venue=v.venue
        where r.discipline_name='Athletics'
),
-- 找出再目标场馆参赛的运动员信息
participating_athletes as(
  -- 处理个人参赛情况
        select
                a.name as athlete_name,
                a.country_code as represented_country_code,
                a.nationality_code
        from
                athletes a
        join
                results r on r.participant_code = a.code and r.participant_type='Person'
        join
                target_venue tv on tv.venue=r.venue
  -- 处理团队参赛情况
        Union
        select
                a.name AS athlete_name,
                a.nationality_code,
                t.country_code AS represented_country_code
        from
                athletes a
        join
                teams t on a.code = t.athletes_code
        join
                results r on r.participant_code = t.code and r.participant_type='Team'
        join
                target_venue tv on tv.venue=r.venue
)
-- 计算国家距离并排序
        select
                pa.athlete_name AS ATHLETE_NAME,
                pa.represented_country_code AS REPRESENTED_COUNTRY_CODE,
                pa.nationality_code AS NATIONALITY_COUNTRY_CODE
        from
                participating_athletes pa
        join
                countries cn on pa.nationality_code=cn.code
        join
                countries cr on pa.represented_country_code=cr.code
        where
                cn.Latitude is not null and
                cn.Longitude is not null and
                cr.Latitude is not null and
                cr.Longitude is not null
        order by
                -- 按距离降序排序
                ((cn.Latitude - cr.Latitude) * (cn.Latitude - cr.Latitude) +
                (cn.Longitude - cr.Longitude) * (cn.Longitude - cr.Longitude)) DESC,
                -- 距离相同时按姓名升序排序
                pa.athlete_name ASC;