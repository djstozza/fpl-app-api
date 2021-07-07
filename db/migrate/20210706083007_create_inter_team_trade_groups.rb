class CreateInterTeamTradeGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :inter_team_trade_groups do |t|
      t.references :out_fpl_team_list, index: true, foreign_key: { to_table: :fpl_team_lists }
      t.references :in_fpl_team_list, index: true, foreign_key: { to_table: :fpl_team_lists }
      t.integer :status, default: 0, null: false
      t.timestamps
    end
  end
end
