WITH trades AS (
  SELECT
  inter_team_trade_group_id,
  JSONB_BUILD_OBJECT(
    'id', inter_team_trades.id::TEXT,
    'out_player',
    JSONB_BUILD_OBJECT(
      'id', out_player.id::TEXT,
      'first_name', out_player.first_name,
      'last_name', out_player.last_name
    ),
    'out_team',
    JSONB_BUILD_OBJECT(
      'id', out_team.id::TEXT,
      'short_name', out_team.short_name
    ),
    'in_player',
    JSONB_BUILD_OBJECT(
      'id', in_player.id::TEXT,
      'first_name', in_player.first_name,
      'last_name', in_player.last_name
    ),
    'in_team',
    JSONB_BUILD_OBJECT(
      'id', in_team.id::TEXT,
      'short_name', in_team.short_name
    ),
    'position', positions.singular_name_short
  ) AS trade_hash
  FROM inter_team_trades
  JOIN players out_player ON inter_team_trades.out_player_id = out_player.id
  JOIN teams out_team ON out_player.team_id = out_team.id
  JOIN players in_player ON inter_team_trades.in_player_id = in_player.id
  JOIN teams in_team ON in_player.team_id = in_team.id
  JOIN positions ON out_player.position_id = positions.id
),

trades_arr AS (
  SELECT
  inter_team_trade_group_id,
  JSONB_AGG(
    DISTINCT
    trade_hash
  ) AS trades
  FROM trades
  GROUP BY inter_team_trade_group_id
),

trade_groups AS (
  SELECT
  out_fpl_team_list_id,
  out_fpl_team.owner_id AS out_owner_id,
  in_fpl_team_list_id,
  in_fpl_team.owner_id AS in_owner_id,
  status,
  JSONB_BUILD_OBJECT(
    'id', inter_team_trade_groups.id::TEXT,
    'out_fpl_team',
    JSONB_BUILD_OBJECT(
      'id', out_fpl_team.id::TEXT,
      'name', out_fpl_team.name
    ),
    'in_fpl_team',
    JSONB_BUILD_OBJECT(
      'id', in_fpl_team.id::TEXT,
      'name', in_fpl_team.name
    ),
    'trades', trades_arr.trades,
    'status',
    CASE
      WHEN status = 0 THEN 'Pending'
      WHEN status = 1 THEN 'Submitted'
      WHEN status = 2 THEN 'Approved'
      WHEN status = 3 THEN 'Declined'
      WHEN status = 4 THEN 'Expired'
    END,
    'can_submit', out_fpl_team.owner_id = :user_id AND status = 0,
    'can_cancel', out_fpl_team.owner_id = :user_id AND (status = 0 OR status = 1),
    'can_approve', in_fpl_team.owner_id = :user_id AND status = 1
  ) AS trade_group_hash
  FROM inter_team_trade_groups
  JOIN trades_arr ON trades_arr.inter_team_trade_group_id = inter_team_trade_groups.id
  JOIN fpl_team_lists out_fpl_team_list ON inter_team_trade_groups.out_fpl_team_list_id = out_fpl_team_list.id
  JOIN fpl_teams out_fpl_team ON out_fpl_team_list.fpl_team_id = out_fpl_team.id
  JOIN fpl_team_lists in_fpl_team_list ON inter_team_trade_groups.in_fpl_team_list_id = in_fpl_team_list.id
  JOIN fpl_teams in_fpl_team ON in_fpl_team_list.fpl_team_id = in_fpl_team.id
  WHERE status != 5 -- Not cancelled
  ORDER BY status
),

out_trade_groups_arr AS (
  SELECT
  out_fpl_team_list_id,
  out_owner_id,
  JSONB_AGG(
    DISTINCT
    trade_group_hash
  ) out_trade_groups
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
    DISTINCT
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
