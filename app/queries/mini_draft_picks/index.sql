SELECT
mini_draft_picks.id::TEXT,
CASE
  WHEN out_player.id IS NOT NULL
  THEN JSONB_BUILD_OBJECT(
    'id', out_player.id::TEXT,
    'first_name', out_player.first_name,
    'last_name', out_player.last_name
  )
END AS out_player,
CASE
  WHEN out_team.id IS NOT NULL
  THEN JSONB_BUILD_OBJECT(
    'id', out_team.id::TEXT,
    'short_name', out_team.short_name
  )
END AS out_team,
CASE
  WHEN in_player.id IS NOT NULL
  THEN JSONB_BUILD_OBJECT(
    'id', in_player.id::TEXT,
    'first_name', in_player.first_name,
    'last_name', in_player.last_name
  )
END AS in_player,
CASE
  WHEN in_team.id IS NOT NULL
  THEN JSONB_BUILD_OBJECT(
    'id', in_team.id::TEXT,
    'short_name', in_team.short_name
  )
END AS in_team,
passed,
CASE
  WHEN positions.id IS NOT NULL THEN positions.singular_name_short
END AS position,
pick_number,
CASE
  WHEN season = 0 THEN 'Summer'
  ELSE 'Winter'
END AS season,
JSONB_BUILD_OBJECT(
  'id', fpl_teams.id::TEXT,
  'name', fpl_teams.name
) AS fpl_team,
JSONB_BUILD_OBJECT(
  'id', users.id::TEXT,
  'username', users.username
) AS user
FROM mini_draft_picks
LEFT JOIN players out_player ON out_player.id = mini_draft_picks.out_player_id
LEFT JOIN positions ON positions.id = out_player.position_id
LEFT JOIN teams out_team ON out_team.id = out_player.team_id
LEFT JOIN players in_player ON in_player.id = mini_draft_picks.in_player_id
LEFT JOIN teams in_team ON in_team.id = in_player.team_id
JOIN fpl_teams ON fpl_teams.id = mini_draft_picks.fpl_team_id
JOIN users ON fpl_teams.owner_id = users.id
WHERE mini_draft_picks.league_id = :league_id
  AND fpl_teams.league_id = :league_id
  AND :season = season
ORDER BY mini_draft_picks.pick_number ASC
