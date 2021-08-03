class AddLeagueIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :leagues, :name, unique: true
  end
end
