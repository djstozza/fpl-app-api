SELECT
players.id::TEXT,
players.external_id::TEXT,
last_name,
first_name,
total_points,
goals_scored,
assists,
minutes,
yellow_cards,
red_cards,
bonus,
players.clean_sheets,
saves,
penalties_saved,
penalties_missed,
own_goals,
status,
chance_of_playing_this_round,
chance_of_playing_next_round,
JSONB_BUILD_OBJECT(
  'id', teams.id::TEXT,
  'short_name', teams.short_name
) AS team,
JSONB_BUILD_OBJECT(
  'id', positions.id::TEXT,
  'singular_name_short', positions.singular_name_short
) AS position
FROM players
JOIN teams ON teams.id = players.team_id
JOIN positions ON positions.id = players.position_id
WHERE (:team_id IS NULL OR team_id IN :team_id)
  AND (:position_id IS NULL OR position_id IN :position_id)
ORDER BY :sort, total_points DESC
LIMIT 50
