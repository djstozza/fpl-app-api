class CreateDraftPicks < ActiveRecord::Migration[6.0]
  def change
    create_table :draft_picks do |t|
      t.integer :pick_number
      t.boolean :mini_draft, default: false, null: false
      t.references :fpl_team, index: true
      t.references :player, index: true
      t.references :league, index: true
      t.timestamps
    end
  end
end
