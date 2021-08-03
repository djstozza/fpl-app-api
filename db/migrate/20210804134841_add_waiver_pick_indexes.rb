class AddWaiverPickIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :waiver_picks, %i[pick_number fpl_team_list_id], unique: true
  end
end
