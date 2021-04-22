class AddIndexesToPlayers < ActiveRecord::Migration[6.0]
  def change
    add_index :players, [:id, :total_points]
    add_index :players, [:id, :goals_scored]
    add_index :players, [:id, :first_name]
    add_index :players, [:id, :last_name]
  end
end
