class AddExternalIdUniqueIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :fixtures, :external_id, unique: true
    add_index :players, :external_id, unique: true
    add_index :positions, :external_id, unique: true
    add_index :rounds, :external_id, unique: true
    add_index :teams, :external_id, unique: true
  end
end
