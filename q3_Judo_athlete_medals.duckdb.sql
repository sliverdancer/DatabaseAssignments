select
      athletes.name as ATHLETE_NAME,
      count(medal_code) as MEDAL_NUMBER
  from
      athletes
  -- 连接teams表，考虑运动员作为团队成员的情况
  left outer join
      teams
  on
--不能写成 athletes.code = teams.code,因为运动员id不可能等于团队id
      athletes.code = teams.athletes_code
  left join
      medals
  on
      teams.code=medals.winner_code OR medals.winner_code=athletes.code
  where
      athletes.disciplines='[''Judo'']'
  group by
      athletes.name
  order by
      MEDAL_NUMBER DESC,
      ATHLETE_NAME ASC;