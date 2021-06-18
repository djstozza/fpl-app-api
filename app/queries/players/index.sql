WITH players AS (:players)

SELECT
players.*,
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
ORDER BY :sort
LIMIT :limit
OFFSET :offset
