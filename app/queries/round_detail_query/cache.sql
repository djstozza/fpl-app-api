SELECT
MAX(GREATEST(rounds.updated_at, fixtures.updated_at)) AS updated_at
FROM rounds
JOIN fixtures ON fixtures.round_id = rounds.id
WHERE rounds.id = :round_id
