class AddFplTeamIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :fpl_teams, :name, unique: true
    add_index :fpl_teams, %i[draft_pick_number league_id], unique: true
    add_index :fpl_teams, %i[mini_draft_pick_number league_id], unique: true
  end
end
