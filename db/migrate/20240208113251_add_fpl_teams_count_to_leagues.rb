class AddFplTeamsCountToLeagues < ActiveRecord::Migration[6.0]
  def change
    add_column :leagues, :fpl_teams_count, :integer, null: false, default: 0
  end
end
