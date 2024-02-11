SELECT
MAX(GREATEST waiver_picks.updated_at, out_player.updated_at, in_player.updated_at, in_team.updated_at, out_team.updated_at) AS updated_at
FROM waiver_picks
JOIN players out_player ON out_player.id = waiver_picks.out_player_id
JOIN positions ON positions.id = out_player.position_id
JOIN teams out_team ON out_team.id = out_player.team_id
JOIN players in_player ON in_player.id = waiver_picks.in_player_id
JOIN teams in_team ON in_team.id = in_player.team_id