WITH list_position_details AS (:list_position_details),

grouped_list_position_details AS (
  SELECT
  fpl_team_list_id,
  JSONB_AGG(list_position_details.*) AS list_positions
  FROM list_position_details
  GROUP BY fpl_team_list_id
)

SELECT
permissions.*,
grouped_list_position_details.list_positions
FROM fpl_team_lists
JOIN fpl_teams ON fpl_team_lists.fpl_team_id = fpl_teams.id
JOIN rounds ON fpl_team_lists.round_id = rounds.id
JOIN grouped_list_position_details ON grouped_list_position_details.fpl_team_list_id = fpl_team_lists.id,
LATERAL (
  SELECT
  ((rounds.is_current AND rounds.data_checked = FALSE) OR rounds.is_next) AS active
) active,
LATERAL (
  SELECT
  fpl_teams.owner_id = :user_id AS is_owner
) is_owner,
LATERAL (
  SELECT
  rounds.deadline_time::TIMESTAMP AS round_deadline
) round_deadline,
LATERAL (
  SELECT
  round_deadline - interval '1 day' AS waiver_deadline
) waiver_deadline,
LATERAL (
  SELECT
  CURRENT_TIMESTAMP < round_deadline AND is_owner AND active AS can_substitute,
  CURRENT_TIMESTAMP < waiver_deadline AND is_owner AND active AS can_waiver_pick,
  CURRENT_TIMESTAMP > waiver_deadline AND CURRENT_TIMESTAMP < round_deadline AND is_owner AND active AS can_trade
) permissions
WHERE fpl_team_lists.id = :fpl_team_list_id
