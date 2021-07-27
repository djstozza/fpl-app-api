SELECT
JSONB_AGG(
  DISTINCT
  JSONB_BUILD_OBJECT(
  	'label', teams.short_name,
  	'value', team_id::TEXT
  )
) AS teams,
JSONB_AGG(
  DISTINCT
  JSONB_BUILD_OBJECT(
  	'label', fpl_teams.name,
  	'value', fpl_teams.id::TEXT
  )
) AS fpl_teams
FROM list_positions
JOIN players ON list_positions.player_id = players.id
JOIN teams ON players.team_id = teams.id
JOIN fpl_team_lists ON list_positions.fpl_team_list_id = fpl_team_lists.id
JOIN fpl_teams ON fpl_team_lists.fpl_team_id = fpl_teams.id
WHERE fpl_teams.league_id = :league_id
	AND fpl_team_lists.round_id = :round_id
	AND players.position_id = :position_id
  AND fpl_team_lists.id != :out_fpl_team_list_id
  AND (:in_fpl_team_list_id IS NULL OR fpl_team_lists.id = :in_fpl_team_list_id)
  AND (:excluded_player_ids IS NULL OR players.id NOT IN :excluded_player_ids)
