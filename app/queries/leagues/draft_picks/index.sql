WITH filtered_draft_picks AS (:filtered_draft_picks),

paged_draft_picks AS (
  SELECT
  league_id,
  draft_pick
  FROM filtered_draft_picks
  OFFSET :offset
  LIMIT :limit
),

grouped_draft_picks AS (
  SELECT
  league_id,
  JSONB_AGG(draft_pick) AS draft_picks
  FROM paged_draft_picks
  GROUP BY league_id
),

next_draft_pick AS (
  SELECT
  users.id AS user_id,
  draft_picks.id AS draft_pick_id,
  fpl_teams.league_id
  FROM draft_picks
  JOIN fpl_teams
    ON draft_picks.fpl_team_id = fpl_teams.id
    AND fpl_teams.league_id = :league_id
  JOIN users ON users.id = fpl_teams.owner_id
  WHERE draft_picks.player_id IS NULL
    AND draft_picks.mini_draft = FALSE
  ORDER BY draft_picks.pick_number
  LIMIT 1
)

SELECT
grouped_draft_picks.draft_picks,
next_draft_pick.draft_pick_id::TEXT AS next_draft_pick_id,
COALESCE(next_draft_pick.user_id = :current_user_id, FALSE) AS user_can_pick,
(
  CASE
    WHEN next_draft_pick.draft_pick_id IS NULL
      THEN TRUE
    ELSE FALSE
  END
) AS draft_finished
FROM grouped_draft_picks
LEFT JOIN next_draft_pick USING (league_id)
