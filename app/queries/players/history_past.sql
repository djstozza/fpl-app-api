SELECT
history_past.*
FROM players
CROSS JOIN LATERAL JSONB_TO_RECORDSET(history_past) history_past(
  season_name TEXT,
  minutes INTEGER,
  total_points INTEGER,
  goals_scored INTEGER,
  assists INTEGER,
  saves INTEGER,
  clean_sheets INTEGER,
  yellow_cards INTEGER,
  red_cards INTEGER,
  goals_conceded INTEGER,
  penalties_saved INTEGER,
  penalties_missed INTEGER,
  own_goals INTEGER,
  bonus INTEGER
)
WHERE players.id = :player_id
ORDER BY :sort, season_name DESC
