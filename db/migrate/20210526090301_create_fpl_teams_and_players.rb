class CreateFplTeamsAndPlayers < ActiveRecord::Migration[6.0]
  def change
    create_join_table :fpl_teams, :players do |t|
      t.index :fpl_team_id
      t.index :player_id
    end
  end
end
