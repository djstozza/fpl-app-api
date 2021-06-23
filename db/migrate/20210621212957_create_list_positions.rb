class CreateListPositions < ActiveRecord::Migration[6.0]
  def change
    create_table :list_positions do |t|
      t.integer :role, null: false
      t.references :fpl_team_list, index: true
      t.references :player, index: true
      t.timestamps
    end

    add_index :list_positions, [:player_id, :fpl_team_list_id], unique: true
  end
end
