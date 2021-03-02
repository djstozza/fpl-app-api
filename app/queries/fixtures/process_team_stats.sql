WITH team_stats_base AS (
  SELECT
  teams.id,
  SUM(
    CASE
      WHEN home THEN fixtures.team_h_score
      WHEN away THEN fixtures.team_a_score
    END
  ) AS goals_for,
  COALESCE(
    SUM(
      CASE
        WHEN home THEN fixtures.team_a_score
        WHEN away THEN fixtures.team_h_score
      END
    ), 0
  ) AS goals_against,
  COALESCE(
  SUM(
    CASE
      WHEN home AND fixtures.team_a_score = 0 THEN 1
      WHEN away AND fixtures.team_h_score = 0 THEN 1
    END
    ), 0
  ) AS clean_sheets,
  COALESCE(
    SUM(
      CASE
        WHEN result = 'W' THEN :winning_points
        WHEN result = 'D' THEN 1
      END
    ), 0
  ) AS points,
  COALESCE(
    SUM(
      CASE
        WHEN result = 'W' THEN 1
      END
    ), 0
  ) AS wins,
  COALESCE (
    SUM(
      CASE
        WHEN result = 'L' THEN 1
      END
    ), 0
  ) AS losses,
  COALESCE(
    SUM(
      CASE
        WHEN result = 'D' THEN 1
      END
    ),
    0
  ) AS draws,
  COUNT(fixtures.id) AS played,
  JSONB_AGG(result ORDER BY fixtures.round_id) AS form
  FROM teams
  JOIN fixtures
    ON fixtures.team_h_id = teams.id
    OR fixtures.team_a_id = teams.id,
  LATERAL (
    SELECT
    fixtures.team_h_id = teams.id AS home,
    fixtures.team_a_id = teams.id AS away
  ) leg,
  LATERAL (
    SELECT
    (
      CASE
        WHEN (
          (home AND fixtures.team_h_score > fixtures.team_a_score) OR
          (away AND fixtures.team_a_score > fixtures.team_h_score)
        )

        THEN 'W'
        WHEN (
          (home AND fixtures.team_a_score > fixtures.team_h_score) OR
          (away AND fixtures.team_h_score > fixtures.team_a_score)
        )
        THEN 'L'
        WHEN fixtures.team_a_score = fixtures.team_h_score
        THEN 'D'
      END
    ) AS result
  ) result
  WHERE fixtures.finished
  GROUP BY teams.id
),

including_goal_difference AS (
  SELECT
  *,
  goals_for - goals_against AS goal_difference
  FROM team_stats_base
),

team_stats AS (
  SELECT
  *,
  RANK () OVER (ORDER BY points DESC, goal_difference DESC) AS position
  FROM including_goal_difference
)

UPDATE teams
SET
goals_for = team_stats.goals_for,
goals_against = team_stats.goals_against,
position = team_stats.position,
played = team_stats.played,
wins = team_stats.wins,
losses = team_stats.losses,
draws = team_stats.draws,
clean_sheets = team_stats.clean_sheets,
form = team_stats.form,
goal_difference = team_stats.goal_difference,
points = team_stats.points
FROM team_stats
WHERE team_stats.id = teams.id
