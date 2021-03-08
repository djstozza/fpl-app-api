SELECT
players.id::TEXT,
players.first_name,
players.last_name,
players.total_points,
players.assists,
players.clean_sheets,
players.yellow_cards,
players.red_cards,
players.bonus,
players.chance_of_playing_next_round,
players.chance_of_playing_this_round,
players.news,
players.news_added,
players.own_goals,
players.penalties_missed,
players.penalties_saved,
players.status,
positions.singular_name_short AS position
FROM players
JOIN positions ON players.position_id = positions.id
WHERE players.team_id = :team_id
