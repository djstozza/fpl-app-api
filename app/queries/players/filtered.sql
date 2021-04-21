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
team_id,
position_id
FROM players
WHERE (:team_id IS NULL OR team_id IN :team_id)
  AND (:position_id IS NULL OR position_id IN :position_id)
