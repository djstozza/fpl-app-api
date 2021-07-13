WITH ordered_mini_draft_picks AS (
  SELECT
  league_id,
  fpl_team_id,
  pick_number,
  passed,
  season
  FROM mini_draft_picks
  WHERE league_id = :league_id
  ORDER BY pick_number DESC
),

passed_fpl_teams AS (
  SELECT
  fpl_teams.id,
  season,
  (
    COUNT(
      CASE
        WHEN passed THEN 1
      END
    ) >= 2
  ) consecutive_passes
  FROM fpl_teams
  JOIN LATERAL (
    SELECT
    *
    FROM ordered_mini_draft_picks
    WHERE fpl_teams.id = fpl_team_id
    LIMIT 2
  ) ordered_mini_draft_picks ON TRUE
  WHERE season = :season
  GROUP BY fpl_teams.id, season
)


SELECT
JSONB_AGG(
  DISTINCT
  fpl_teams.id
)
FROM fpl_teams
WHERE fpl_teams.id NOT IN (SELECT id FROM passed_fpl_teams WHERE consecutive_passes)
