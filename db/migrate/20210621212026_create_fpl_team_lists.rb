class CreateFplTeamLists < ActiveRecord::Migration[6.0]
  def change
    create_table :fpl_team_lists do |t|
      t.integer :round_rank
      t.integer :cumulative_rank
      t.integer :total_score
      t.references :fpl_team, index: true
      t.references :round, index: true
      t.timestamps
    end

    add_index :fpl_team_lists, [:fpl_team_id, :round_id], unique: true
  end
end
