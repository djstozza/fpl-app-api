SELECT
MAX(GREATEST(teams.updated_at, fixtures.updated_at, players.updated_at)) AS updated_at
FROM teams
JOIN fixtures ON fixtures.team_h_id = teams.id OR fixtures.team_a_id = teams.id
JOIN players ON players.team_id = teams.id
WHERE teams.id = :team_id
