class AddIndexesToPlayers < ActiveRecord::Migration[6.0]
  def change
    add_index :players, %i[id total_points]
    add_index :players, %i[id goals_scored]
    add_index :players, %i[id first_name]
    add_index :players, %i[id last_name]
  end
end
