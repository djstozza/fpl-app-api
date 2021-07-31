WITH trade_groups AS (:trade_groups)

SELECT
trade_group_hash
FROM trade_groups
WHERE id = :inter_team_trade_group_id
  AND out_owner_id = :user_id
