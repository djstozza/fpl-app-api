SELECT DISTINCT ON(role, display_order, fixtures.id, players.id)
list_positions.id::TEXT,
fpl_team_lists.id AS fpl_team_list_id,
JSONB_BUILD_OBJECT(
  'id', players.id::TEXT,
  'first_name', first_name,
  'last_name', last_name
) AS player,
singular_name_short AS position,
CASE
  WHEN singular_name_short = 'FWD' THEN 0
  WHEN singular_name_short = 'MID' THEN 1
  WHEN singular_name_short = 'DEF' THEN 3
  WHEN singular_name_short = 'GKP' THEN 4
END AS display_order,
role,
fixtures.kickoff_time,
fixtures.started,
fixtures.finished,
history.*,
JSONB_BUILD_OBJECT(
  'id', teams.id::TEXT,
  'short_name', teams.short_name
) AS team,
JSONB_BUILD_OBJECT(
  'id', opposition_team.id::TEXT,
  'short_name', opposition_team.short_name
) AS opponent,
CASE
  WHEN role = 0 THEN 'Starting'
  WHEN role = 1 THEN 'S1'
  WHEN role = 2 THEN 'S2'
  WHEN role = 3 THEN 'S3'
  WHEN role = 4 THEN 'SGKP'
END AS role_str,
CASE
  WHEN teams.id = fixtures.team_h_id THEN 'H'
  ELSE 'A'
END AS leg
FROM list_positions
JOIN players ON list_positions.player_id = players.id
JOIN positions ON players.position_id = positions.id
JOIN teams player_team ON players.team_id = player_team.id
JOIN fpl_team_lists ON list_positions.fpl_team_list_id = fpl_team_lists.id
JOIN rounds ON fpl_team_lists.round_id = rounds.id
LEFT JOIN LATERAL JSONB_TO_RECORDSET(players.history)
  history(
    round INTEGER,
    fixture INTEGER,
    opponent_team INTEGER,
    minutes INTEGER,
    total_points INTEGER,
    goals_scored INTEGER,
    assists INTEGER,
    clean_sheets INTEGER,
    saves INTEGER,
    yellow_cards INTEGER,
    red_cards INTEGER,
    penalties_saved INTEGER,
    penalties_missed INTEGER,
    bonus INTEGER,
    goals_conceded INTEGER,
    own_goals INTEGER
  )
  ON rounds.external_id = history.round
JOIN fixtures
  ON fixtures.round_id = rounds.id
  AND (
    (history.fixture IS NULL AND (fixtures.team_h_id = player_team.id OR fixtures.team_a_id = player_team.id))
    OR history.fixture = fixtures.external_id
  )
JOIN teams opposition_team
  ON (
    history.opponent_team IS NULL
      AND (
        (fixtures.team_a_id = opposition_team.id AND fixtures.team_h_id = player_team.id) OR
        (fixtures.team_h_id = opposition_team.id AND fixtures.team_a_id = player_team.id)
      )
    )
    OR history.opponent_team = opposition_team.external_id
/*
Need to deliniate between the player's team and the team that's in the fixture, as a player may be in team A in round 1
but be traded to team B in round 20. The change in teams means that fixture information may not be correct so it is best
to use the history data if present to ensure that the correct information is displayed for past games.

Default to the player's team if no history information is present for the round in question.
*/
JOIN teams
  ON (history.opponent_team IS NULL AND teams.id = player_team.id)
  OR (fixtures.team_h_id = teams.id AND teams.id != opposition_team.id)
  OR (fixtures.team_a_id = teams.id AND teams.id != opposition_team.id)
WHERE fpl_team_lists.id = :fpl_team_list_id
ORDER BY role ASC, display_order, players.id ASC, fixtures.id ASC
