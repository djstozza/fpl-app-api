SELECT
MAX(GREATEST(fixtures.updated_at, rounds.updated_at, opposition_team.updated_at)) AS last_modified
FROM teams
JOIN fixtures ON fixtures.team_h_id = teams.id OR fixtures.team_a_id = teams.id
JOIN rounds ON rounds.id = fixtures.round_id
JOIN teams opposition_team ON (
  fixtures.team_a_id = opposition_team.id AND fixtures.team_h_id = teams.id
) OR (
  fixtures.team_h_id = opposition_team.id AND fixtures.team_a_id = teams.id
)
WHERE teams.id = :team_id
