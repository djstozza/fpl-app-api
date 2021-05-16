class CreateLeagues < ActiveRecord::Migration[6.0]
  def change
    create_table :leagues do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.integer :status, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.references :owner, references: :user, index: true
      t.timestamps
    end
  end
end
