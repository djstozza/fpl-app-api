SELECT
  draft_picks.id::TEXT,
  draft_picks.pick_number,
  draft_picks.mini_draft,
  JSONB_BUILD_OBJECT(
    'id', fpl_teams.id::TEXT,
    'name', fpl_teams.name
  ) AS fpl_team,
  JSONB_BUILD_OBJECT(
    'id', users.id::TEXT,
    'username', users.username
  ) AS user,
  (
    CASE
      WHEN players.id IS NOT NULL
      THEN (
        JSONB_BUILD_OBJECT(
          'id', players.id::TEXT,
          'first_name', players.first_name,
          'last_name', players.last_name
        )
      )
      ELSE null
    END
  ) AS player,
  (
    CASE
      WHEN teams.id IS NOT NULL
      THEN (
        JSONB_BUILD_OBJECT(
          'id', teams.id::TEXT,
          'short_name', teams.short_name
        )
      )
      ELSE NULL
    END
  ) AS team,
  (
    CASE
      WHEN positions.id IS NOT NULL
      THEN positions.singular_name_short
      ELSE NULL
    END
  ) AS position
FROM leagues
JOIN fpl_teams ON fpl_teams.league_id = leagues.id
JOIN draft_picks
  ON draft_picks.fpl_team_id = fpl_teams.id
  AND draft_picks.league_id = leagues.id
JOIN users ON users.id = fpl_teams.owner_id
LEFT JOIN players ON players.id = draft_picks.player_id
LEFT JOIN teams ON teams.id = players.team_id
LEFT JOIN positions ON positions.id = players.position_id
WHERE leagues.id = :league_id
  AND (:mini_draft IS NULL OR mini_draft = TRUE)
  AND (:position_id IS NULL OR positions.id IN :position_id)
  AND (:team_id IS NULL OR teams.id IN :team_id)
  AND (:fpl_team_id IS NULL OR fpl_teams.id IN :fpl_team_id)
ORDER BY :sort
