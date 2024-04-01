SELECT
history.kickoff_time,
history.minutes,
history.goals_scored,
history.assists,
history.saves,
history.own_goals,
(
  CASE
    WHEN history.was_home
      THEN 'H'
    ELSE 'A'
  END
) AS leg,
history.total_points,
history.clean_sheets,
history.team_h_score AS home_team_score,
history.team_a_score AS away_team_score,
history.yellow_cards,
history.red_cards,
history.penalties_saved,
history.penalties_missed,
history.bonus,
fixtures.started,
(
  CASE
    WHEN (
      (history.was_home AND history.team_h_score > history.team_a_score)
        OR (history.was_home = FALSE AND history.team_a_score > history.team_h_score)
    ) AND fixtures.finished
      THEN 'W'
    WHEN (
      (history.was_home AND history.team_h_score < history.team_a_score)
        OR (history.was_home = FALSE AND history.team_a_score < history.team_h_score)
    ) AND fixtures.finished
      THEN 'L'
    WHEN history.team_h_score = history.team_a_score AND fixtures.finished
      THEN 'D'
  END
) AS result,
JSONB_BUILD_OBJECT(
  'id', opposition_team.id::TEXT,
  'short_name', opposition_team.short_name
) AS opponent,
JSONB_BUILD_OBJECT(
  'id', round::TEXT,
  'name', rounds.name
) AS round
FROM
players
CROSS JOIN LATERAL JSONB_TO_RECORDSET(history) history(
  kickoff_time TEXT,
  minutes INTEGER,
  goals_scored INTEGER,
  assists INTEGER,
  saves INTEGER,
  own_goals INTEGER,
  was_home BOOLEAN,
  bonus INTEGER,
  total_points INTEGER,
  opponent_team INTEGER,
  clean_sheets INTEGER,
  team_h_score INTEGER,
  team_a_score INTEGER,
  yellow_cards INTEGER,
  penalties_saved INTEGER,
  penalties_missed INTEGER,
  red_cards INTEGER,
  round INTEGER,
  fixture INTEGER
)
JOIN teams opposition_team
  ON opposition_team.external_id = opponent_team
JOIN rounds
  ON rounds.external_id = round
JOIN fixtures
  ON fixtures.external_id = fixture
WHERE players.id = :player_id
ORDER BY :sort, kickoff_time
