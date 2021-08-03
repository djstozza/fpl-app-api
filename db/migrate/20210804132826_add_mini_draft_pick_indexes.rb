class AddMiniDraftPickIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :mini_draft_picks, %i[pick_number league_id season], unique: true
  end
end
