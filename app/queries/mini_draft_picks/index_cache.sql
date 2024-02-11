SELECT
MAX(GREATEST(mini_draft_picks.updated_at, fpl_teams.updated_at, users.updated_at)) AS last_modified
FROM mini_draft_picks
JOIN fpl_teams ON fpl_teams.id = mini_draft_picks.fpl_team_id
JOIN users ON fpl_teams.owner_id = users.id
WHERE mini_draft_picks.league_id = :league_id
  AND fpl_teams.league_id = :league_id
  AND :season = season