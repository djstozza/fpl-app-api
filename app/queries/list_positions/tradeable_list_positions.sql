SELECT
list_positions.id::TEXT,
fpl_team_list_id::TEXT,
JSONB_BUILD_OBJECT(
  'id', players.id::TEXT,
  'first_name', first_name,
  'last_name', last_name
) AS player,
JSONB_BUILD_OBJECT(
  'id', positions.id::TEXT,
  'singular_name_short', singular_name_short
) AS position,
JSONB_BUILD_OBJECT(
  'id', teams.id::TEXT,
  'short_name', teams.short_name
) AS team,
JSONB_BUILD_OBJECT(
  'id', fpl_teams.id::TEXT,
  'name', fpl_teams.name
) AS fpl_team
FROM list_positions
JOIN fpl_team_lists ON list_positions.fpl_team_list_id = fpl_team_lists.id
JOIN fpl_teams ON fpl_team_lists.fpl_team_id = fpl_teams.id
JOIN players ON list_positions.player_id = players.id
JOIN teams ON players.team_id = teams.id
JOIN positions ON players.position_id = positions.id
WHERE fpl_team_lists.round_id = :round_id
  AND fpl_teams.league_id = :league_id
  AND positions.id = :position_id
  AND fpl_team_lists.id != :out_fpl_team_list_id
  AND (:in_fpl_team_list_id IS NULL OR fpl_team_lists.id = :in_fpl_team_list_id)
  AND (:team_id IS NULL OR teams.id IN :team_id)
  AND (:fpl_team_id IS NULL OR fpl_teams.id IN :fpl_team_id)
  AND (:excluded_player_ids IS NULL OR players.id NOT IN :excluded_player_ids)
ORDER BY :sort
