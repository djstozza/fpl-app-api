WITH player_facets AS (
  SELECT
  mini_draft_picks.league_id,
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
      'label', out_team.short_name,
      'value', out_team.id::TEXT
    )
  ) AS out_teams,
  JSONB_AGG(
    DISTINCT
    JSONB_BUILD_OBJECT(
      'label', in_team.short_name,
      'value', in_team.id::TEXT
    )
  ) AS in_teams
  FROM mini_draft_picks
  JOIN players out_player ON mini_draft_picks.out_player_id = out_player.id
  JOIN positions ON out_player.position_id = positions.id
  JOIN teams out_team ON out_player.team_id = out_team.id
  JOIN players in_player ON mini_draft_picks.in_player_id = in_player.id
  JOIN teams in_team ON in_player.team_id = in_team.id
  JOIN leagues ON mini_draft_picks.league_id = leagues.id
  WHERE season = :season
  GROUP BY mini_draft_picks.league_id
),

fpl_team_facets AS (
  SELECT
  mini_draft_picks.league_id,
  JSONB_AGG(
    DISTINCT
    JSONB_BUILD_OBJECT(
      'label', fpl_teams.name,
      'value', fpl_teams.id::TEXT
    )
  ) AS fpl_teams
  FROM mini_draft_picks
  JOIN fpl_teams ON fpl_teams.id = mini_draft_picks.fpl_team_id
  WHERE season = :season
  GROUP BY mini_draft_picks.league_id
),

passed_facets AS (
  SELECT
  mini_draft_picks.league_id,
  JSONB_AGG(
    DISTINCT
    JSONB_BUILD_OBJECT(
      'label', (
        CASE
          WHEN passed = TRUE
            THEN 'Yes'
          ELSE 'No'
        END
      ),
      'value', passed
    )
  ) AS passed
  FROM mini_draft_picks
  JOIN fpl_teams ON fpl_teams.id = mini_draft_picks.fpl_team_id
  GROUP BY mini_draft_picks.league_id
)

SELECT
COALESCE(player_facets.positions, '[]') AS positions,
COALESCE(player_facets.out_teams, '[]') AS out_teams,
COALESCE(player_facets.in_teams, '[]') AS in_teams,
fpl_team_facets.fpl_teams,
passed_facets.passed
FROM leagues
LEFT JOIN player_facets ON player_facets.league_id = leagues.id
LEFT JOIN fpl_team_facets ON fpl_team_facets.league_id = leagues.id
LEFT JOIN passed_facets ON passed_facets.league_id = leagues.id
WHERE leagues.id = :league_id
