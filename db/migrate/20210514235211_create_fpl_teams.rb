class CreateFplTeams < ActiveRecord::Migration[6.0]
  def change
    create_table :fpl_teams do |t|
      t.string :name, null: false
      t.integer :draft_pick_number
      t.integer :mini_draft_pick_number
      t.integer :rank
      t.references :owner, references: :user, index: true
      t.references :league, index: true
      t.timestamps
    end
  end
end
