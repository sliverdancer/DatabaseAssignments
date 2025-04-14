select
      coaches.name as COACH_NAME,
      count(medals.medal_code) as MEDAL_NUMBER
  from
      medals
  join
      teams
  on
      medals.winner_code=teams.code
  join
      coaches
  on
      teams.country_code=coaches.country_code
  group by
      coaches.name
  order by
      MEDAL_NUMBER DESC,
      COACH_NAME ASC;