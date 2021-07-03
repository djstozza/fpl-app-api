SELECT
waiver_picks.id::TEXT,
waiver_picks.pick_number,
JSONB_BUILD_OBJECT(
  'id', out_player.id::TEXT,
  'first_name', out_player.first_name,
  'last_name', out_player.last_name
) AS out_player,
JSONB_BUILD_OBJECT(
  'id', out_team.id::TEXT,
  'short_name', out_team.short_name
) AS out_team,
JSONB_BUILD_OBJECT(
  'id', in_player.id::TEXT,
  'first_name', in_player.first_name,
  'last_name', in_player.last_name
) AS in_player,
JSONB_BUILD_OBJECT(
  'id', in_team.id::TEXT,
  'short_name', in_team.short_name
) AS in_team,
positions.singular_name_short AS position,
CASE
  WHEN waiver_picks.status = 0 THEN 'Pending'
  WHEN waiver_picks.status = 1 THEN 'Approved'
  WHEN waiver_picks.status = 2 THEN 'Declined'
END as status
FROM waiver_picks
JOIN players out_player ON out_player.id = waiver_picks.out_player_id
JOIN positions ON positions.id = out_player.position_id
JOIN teams out_team ON out_team.id = out_player.team_id
JOIN players in_player ON in_player.id = waiver_picks.in_player_id
JOIN teams in_team ON in_team.id = in_player.id
JOIN fpl_team_lists ON fpl_team_lists.id = waiver_picks.fpl_team_list_id
JOIN fpl_teams ON fpl_teams.id = fpl_team_lists.fpl_team_id
WHERE fpl_team_lists.id = :fpl_team_list_id
  AND fpl_teams.owner_id = :user_id
  AND waiver_picks.status != 3  -- Not cancelled
ORDER BY waiver_picks.pick_number ASC
