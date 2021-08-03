class AddDraftPickIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :draft_picks, %i[pick_number league_id], unique: true
    add_index :draft_picks, %i[player_id league_id], unique: true
  end
end
