class CreateRounds < ActiveRecord::Migration[6.0]
  def change
    create_table :rounds do |t|
      t.string :name
      t.string :deadline_time
      t.boolean :finished
      t.boolean :data_checked
      t.integer :deadline_time_epoch
      t.integer :deadline_time_game_offset
      t.boolean :is_previous
      t.boolean :is_current
      t.boolean :is_next
      t.integer :external_id
      t.timestamps
    end
  end
end
