class CreatePositions < ActiveRecord::Migration[6.0]
  def change
    create_table :positions do |t|
      t.string :singular_name
      t.string :singular_name_short
      t.string :plural_name
      t.string :plural_name_short
      t.integer :squad_select
      t.integer :squad_min_play
      t.integer :squad_max_play
      t.integer :external_id
      t.timestamps
    end
  end
end
