class AddInterTeamTradeIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :inter_team_trades,
              %i[out_player_id inter_team_trade_group_id],
              unique: true,
              name: 'unique_out_player'
    add_index :inter_team_trades,
              %i[in_player_id inter_team_trade_group_id],
              unique: true,
              name: 'unique_in_player'
  end
end
