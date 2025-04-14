WITH ranked_results AS (
    -- 处理个人和团队数据，获取国家代码并筛选rank <=5
    SELECT
        r.date,
        -- 个人参赛：从athletes获取country_code
        CASE
            WHEN r.participant_type = 'Person' THEN a.country_code
            -- 团队参赛：从teams获取country_code
            WHEN r.participant_type = 'Team' THEN t.country_code
        END AS country_code
    FROM
        results r
    -- 左连接athletes处理个人情况
    LEFT JOIN athletes a
        ON r.participant_type = 'Person' AND r.participant_code = a.code
    -- 左连接teams处理团队情况
    LEFT JOIN teams t
        ON r.participant_type = 'Team' AND r.participant_code = t.code
    WHERE
        r.rank <= 5 AND r.rank IS NOT NULL  -- 筛选top5有效记录
),
daily_country_counts AS (
    -- 按日期和国家代码统计出现次数
    SELECT
        date,
        country_code,
        COUNT(*) AS top5_appearances
    FROM
        ranked_results
    GROUP BY
        date, country_code
),
daily_max_country as(
        --排名（出现次数降序，国家代码升序）
        select
                date,
                country_code,
                top5_appearances,
                ROW_NUMBER() over(
                        partition by date
                        order by top5_appearances DESC,country_code ASC
                ) as rn
        from
                daily_country_counts
)
select
        dmc.date as DATE,
        dmc.country_code as COUNTRY_CODE,
        dmc.top5_appearances TOP5_APPEARANCES,
        rank() over(order by c."GDP ($ per capita)" DESC) as GDP_RANK,
        rank() over(order by c.Population DESC) as POPULATION_RANK
from
        daily_max_country dmc
join countries c
        on dmc.country_code=c.code
where
        dmc.rn=1    -- 只取每日出现次数最多的国家（处理后排名为1）
order by
        dmc.date ASC;