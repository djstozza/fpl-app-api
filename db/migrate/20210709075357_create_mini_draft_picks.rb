class CreateMiniDraftPicks < ActiveRecord::Migration[6.0]
  def change
    create_table :mini_draft_picks do |t|
      t.integer :pick_number
      t.integer :season, null: false
      t.boolean :passed, default: false, null: false
      t.references :out_player, index: true, foreign_key: { to_table: :players }
      t.references :in_player, index: true, foreign_key: { to_table: :players }
      t.references :fpl_team, index: true
      t.references :league, index: true
      t.timestamps
    end
  end
end
