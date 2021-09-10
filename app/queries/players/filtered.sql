WITH league_player_ids AS (
  SELECT
  players.id
  FROM players
  JOIN fpl_teams_players ON fpl_teams_players.player_id = players.id
  JOIN fpl_teams ON fpl_teams_players.fpl_team_id = fpl_teams.id
  JOIN leagues
    ON fpl_teams.league_id = leagues.id
    AND leagues.id = :league_id
)

SELECT DISTINCT
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
players.status,
news,
news_added,
chance_of_playing_this_round,
chance_of_playing_next_round,
team_id,
position_id
FROM players
LEFT JOIN fpl_teams_players ON fpl_teams_players.player_id = players.id
LEFT JOIN fpl_teams ON fpl_teams_players.fpl_team_id = fpl_teams.id
LEFT JOIN leagues ON fpl_teams.league_id = leagues.id
WHERE (:team_id IS NULL OR team_id IN :team_id)
  AND (:position_id IS NULL OR position_id IN :position_id)
  AND (:league_id IS NULL OR players.id NOT IN (SELECT id FROM league_player_ids))
  AND (:status IS NULL OR players.status IN :status)
