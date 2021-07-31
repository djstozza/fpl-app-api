WITH trade_groups AS (:trade_groups),

out_trade_groups_arr AS (
  SELECT
  out_fpl_team_list_id,
  out_owner_id,
  JSONB_AGG(
    trade_group_hash
  )  out_trade_groups
  FROM trade_groups
  GROUP BY out_fpl_team_list_id, out_owner_id
),

in_trade_groups AS (
  SELECT
  *
  FROM trade_groups
  WHERE status != 0 -- Should not see any pending trades
),

in_trade_groups_arr AS (
  SELECT
  in_fpl_team_list_id,
  in_owner_id,
  JSONB_AGG(
    trade_group_hash
  ) in_trade_groups
  FROM in_trade_groups
  GROUP BY in_fpl_team_list_id, in_owner_id
)

SELECT
COALESCE(out_trade_groups_arr.out_trade_groups, '[]') AS out_trade_groups,
COALESCE(in_trade_groups_arr.in_trade_groups, '[]') AS in_trade_groups
FROM fpl_team_lists
LEFT JOIN out_trade_groups_arr
  ON out_fpl_team_list_id = fpl_team_lists.id
  AND out_owner_id = :user_id
LEFT JOIN in_trade_groups_arr
  ON in_fpl_team_list_id = fpl_team_lists.id
  AND in_owner_id = :user_id
WHERE fpl_team_lists.id = :fpl_team_list_id
