class AddMiniDraftToRounds < ActiveRecord::Migration[6.0]
  def change
    add_column :rounds, :mini_draft, :boolean, default: false, null: false
  end
end
