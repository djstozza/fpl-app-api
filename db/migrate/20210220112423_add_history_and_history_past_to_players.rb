class AddHistoryAndHistoryPastToPlayers < ActiveRecord::Migration[6.0]
  def change
    add_column :players, :history, :jsonb
    add_column :players, :history_past, :jsonb
  end
end
