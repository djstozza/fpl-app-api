WITH next_draft_pick AS (
  SELECT
  draft_picks.id AS draft_pick_id,
  owner_id AS user_id,
  draft_picks.league_id
  FROM draft_picks
  JOIN fpl_teams
    ON draft_picks.fpl_team_id = fpl_teams.id
    AND fpl_teams.league_id = draft_picks.league_id
    WHERE draft_picks.player_id IS NULL
    AND draft_picks.mini_draft = FALSE
    ORDER BY draft_picks.pick_number
    LIMIT 1
)

SELECT
draft_pick_id::TEXT AS next_draft_pick_id,
COALESCE(user_id = :current_user_id, FALSE) AS user_can_pick,
(
  CASE
    WHEN draft_pick_id IS NULL AND :can_draft
      THEN TRUE
    ELSE FALSE
  END
) AS draft_finished
FROM leagues
LEFT JOIN next_draft_pick ON leagues.id = next_draft_pick.league_id
WHERE leagues.id = 1
