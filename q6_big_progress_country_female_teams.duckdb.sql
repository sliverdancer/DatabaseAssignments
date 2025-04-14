with gold_improvement as (
        --计算每个国家的金牌增长
        select
                tm.country_code,
                (coalesce(c.current_gold,0)-tm.gold_medal) as increased_gold
        from
                tokyo_medals tm
        left join(
        --统计当前每个国家的金牌数(通过medal_info表的name属性来计算）
                select
                        a.country_code,   --用于作为连接条件的
                        count(*) as current_gold  --以国家分组
                from
                        medals m
                join
                        athletes a on m.winner_code=a.code
                join
                        medal_info mi on m.medal_code=mi.code
                where
                        mi.name='Gold Medal'
                group by
                        a.country_code
        )c on tm.country_code=c.country_code
),
top_five_countries as(
        select
                country_code,
                increased_gold
        from
                gold_improvement gi
        order by
                increased_gold DESC,
                country_code ASC
        --列出5个
        limit 5
)
--选出全女性的团队
select
        tf.country_code as COUNTRY_CODE,
        tf.increased_gold as INCREASED_GOLD_MEDAL_NUMBER,
        t.team_code as TEAM_CODE
from
        top_five_countries tf
CROSS JOIN LATERAL(
        select
                code as team_code
        from
                teams
        where
                teams.country_code=tf.country_code --匹配外表中的国家号
                and not exists(  --不存在不满足的情况（反向筛选）
                        -- 检查团队中是否所有运动员都为女性且存在
                        select 1  -- 只要存在一行满足条件，NOT EXISTS 就不成立（即团队不符合条件）
                        from
                                unnest(string_split(teams.athletes_code, ',')) as athlete_code(value)  --按逗号分割并拆分成多行数据
                        left join
                                athletes a on a.code = athlete_code.value   --检查运动员是否存在
                        left join
                                gender g on a.gender=g.id   --关联性别表，检查运动员性别
                        where
                                g.name!='Female' or a.code is null
                        )
                )t
        order by
                tf.country_code ASC,
                tf.increased_gold DESC,
                t.team_code ASC;