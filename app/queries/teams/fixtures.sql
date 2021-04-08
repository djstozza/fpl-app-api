SELECT
fixtures.id::TEXT,
JSONB_BUILD_OBJECT(
  'id', rounds.id::TEXT,
  'name', rounds.name
) AS round,
fixtures.started,
fixtures.finished,
fixtures.minutes,
fixtures.kickoff_time,
fixtures.team_a_score AS away_team_score,
fixtures.team_h_score AS home_team_score,
JSONB_BUILD_OBJECT(
  'id', opposition_team.id::TEXT,
  'short_name', opposition_team.short_name
) AS opponent,
(
  CASE
    WHEN fixtures.team_h_id = teams.id
    THEN 'H'
    ELSE 'A'
  END
) AS leg,
result,
fixture_details.strength
FROM teams
JOIN fixtures ON fixtures.team_h_id = teams.id OR fixtures.team_a_id = teams.id
JOIN rounds ON fixtures.round_id = rounds.id
JOIN teams opposition_team ON (
  fixtures.team_a_id = opposition_team.id AND fixtures.team_h_id = teams.id
) OR (
  fixtures.team_h_id = opposition_team.id AND fixtures.team_a_id = teams.id
),
LATERAL (
  SELECT
  (
    CASE
      WHEN (
        (team_h_id = teams.id AND team_h_score > team_a_score) OR
        (team_a_id = teams.id AND team_a_score > team_h_score)
      ) AND fixtures.finished
      THEN 'W'
      WHEN (
        (team_h_id = teams.id AND team_h_score < team_a_score) OR
        (team_a_id = teams.id AND team_a_score < team_h_score)
      ) AND fixtures.finished
      THEN 'L'
      WHEN team_h_score = team_a_score AND fixtures.finished
      THEN 'D'
    END
  ) AS result,
  (
    CASE
      WHEN team_h_id = teams.id
      THEN team_a_difficulty - team_h_difficulty
      WHEN team_a_id = teams.id
      THEN team_h_difficulty - team_a_difficulty
    END
  ) AS strength
) fixture_details
WHERE teams.id = :team_id
ORDER BY :sort, kickoff_time ASC
