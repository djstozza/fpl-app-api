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
),

fpl_team_status AS (
  SELECT
  draft_picks.league_id,
  COUNT(CASE WHEN mini_draft = TRUE THEN 1 END) = 0 AS can_make_mini_draft_pick,
  COUNT(CASE WHEN player_id IS NOT NULL THEN 1 END) < :player_quota AS can_make_player_pick
  FROM draft_picks
  JOIN fpl_teams
  	ON fpl_teams.id = draft_picks.fpl_team_id
  	AND fpl_teams.owner_id = :current_user_id
  GROUP BY draft_picks.league_id
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
) AS draft_finished,
can_make_player_pick,
can_make_mini_draft_pick
FROM leagues
LEFT JOIN next_draft_pick ON leagues.id = next_draft_pick.league_id
JOIN fpl_team_status ON fpl_team_status.league_id = leagues.id
WHERE leagues.id = :league_id
