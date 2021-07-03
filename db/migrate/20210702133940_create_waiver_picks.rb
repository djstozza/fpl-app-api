class CreateWaiverPicks < ActiveRecord::Migration[6.0]
  def change
    create_table :waiver_picks do |t|
      t.integer :pick_number, null: false
      t.integer :status, default: 0, null: false
      t.references :out_player, index: true, foreign_key: { to_table: :players }
      t.references :in_player, index: true, foreign_key: { to_table: :players }
      t.references :fpl_team_list, index: true
      t.timestamps
    end
  end
end
