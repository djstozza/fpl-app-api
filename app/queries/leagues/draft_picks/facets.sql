WITH player_facets AS (
  SELECT
  draft_picks.league_id,
  JSONB_AGG(
    DISTINCT
    JSONB_BUILD_OBJECT(
      'label', positions.singular_name_short,
      'value', positions.id::TEXT
    )
  ) AS positions,
  JSONB_AGG(
    DISTINCT
    JSONB_BUILD_OBJECT(
      'label', teams.short_name,
      'value', teams.id::TEXT
    )
  ) AS teams
  FROM draft_picks
  JOIN players ON draft_picks.player_id = players.id
  JOIN positions ON players.position_id = positions.id
  JOIN teams ON players.team_id = teams.id
  JOIN leagues ON draft_picks.league_id = leagues.id
  GROUP BY draft_picks.league_id
),

fpl_team_facets AS (
  SELECT
  draft_picks.league_id,
  JSONB_AGG(
    DISTINCT
    JSONB_BUILD_OBJECT(
      'label', fpl_teams.name,
      'value', fpl_teams.id::TEXT
    )
  ) AS fpl_teams
  FROM draft_picks
  JOIN fpl_teams ON fpl_teams.id = draft_picks.fpl_team_id
  GROUP BY draft_picks.league_id
),

mini_draft_facets AS (
  SELECT
  draft_picks.league_id,
  JSONB_AGG(
    DISTINCT
    JSONB_BUILD_OBJECT(
      'label', (
        CASE
          WHEN mini_draft = TRUE
            THEN 'Yes'
          ELSE 'No'
        END
      ),
      'value', mini_draft
    )
  ) AS mini_draft
  FROM draft_picks
  LEFT JOIN players ON draft_picks.player_id = players.id
  LEFT JOIN positions ON players.position_id = positions.id
  LEFT JOIN teams ON players.team_id = teams.id
  JOIN fpl_teams ON fpl_teams.id = draft_picks.fpl_team_id
  GROUP BY draft_picks.league_id
)

SELECT
COALESCE(player_facets.positions, '[]') AS positions,
COALESCE(player_facets.teams, '[]') AS teams,
fpl_team_facets.fpl_teams,
mini_draft_facets.mini_draft
FROM leagues
LEFT JOIN player_facets ON player_facets.league_id = leagues.id
LEFT JOIN fpl_team_facets ON fpl_team_facets.league_id = leagues.id
LEFT JOIN mini_draft_facets ON mini_draft_facets.league_id = leagues.id
WHERE leagues.id = :league_id
