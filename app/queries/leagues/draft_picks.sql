WITH next_draft_pick_user AS (
  SELECT
  users.id AS user_id,
  draft_picks.fpl_team_id,
  fpl_teams.league_id
  FROM draft_picks
  JOIN fpl_teams
    ON draft_picks.fpl_team_id = fpl_teams.id
    AND fpl_teams.league_id = :league_id
  JOIN users ON users.id = fpl_teams.owner_id
  WHERE draft_picks.player_id IS NULL
    AND draft_picks.mini_draft = FALSE
  ORDER BY draft_picks.pick_number
  LIMIT 1
),

draft_picks AS (
  SELECT
  leagues.id AS league_id,
  JSONB_AGG(
    DISTINCT
    JSONB_BUILD_OBJECT(
      'id', draft_picks.id::TEXT,
      'pick_number', draft_picks.pick_number,
      'mini_draft', draft_picks.mini_draft,
      'fpl_team', JSONB_BUILD_OBJECT(
        'id', fpl_teams.id::TEXT,
        'name', fpl_teams.name
      ),
      'user', JSONB_BUILD_OBJECT(
        'id', users.id::TEXT,
        'username', users.username
      ),
      'player', (
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
      ),
      'team', (
        CASE
          WHEN teams.id IS NOT NULL
          THEN (
            JSONB_BUILD_OBJECT(
              'id', teams.id::TEXT,
              'short_name', teams.short_name
            )
          )
          ELSE null
        END
      ),
      'position', (
        CASE
          WHEN positions.id IS NOT NULL
          THEN positions.singular_name_short
          ELSE null
        END
      )
    )
  ) AS draft_picks
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
  GROUP BY leagues.id
)

SELECT
draft_picks.draft_picks,
COALESCE(next_draft_pick_user.user_id = :current_user_id, FALSE) AS user_can_pick,
(
  CASE
    WHEN next_draft_pick_user.user_id IS NULL
      THEN TRUE
    ELSE FALSE
  END
) AS draft_finished
FROM draft_picks
LEFT JOIN next_draft_pick_user USING (league_id)
