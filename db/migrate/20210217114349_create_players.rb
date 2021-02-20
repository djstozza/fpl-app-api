class CreatePlayers < ActiveRecord::Migration[6.0]
  def change
    create_table :players do |t|
      t.integer :chance_of_playing_next_round
      t.integer :chance_of_playing_this_round
      t.integer :code
      t.integer :dreamteam_count
      t.integer :event_points
      t.string :first_name
      t.string :last_name
      t.decimal :form
      t.integer :external_id
      t.boolean :in_dreamteam
      t.string :news
      t.datetime :news_added
      t.string :photo
      t.decimal :points_per_game
      t.decimal :selected_by_percent
      t.boolean :special
      t.string :status
      t.integer :total_points
      t.integer :minutes
      t.integer :goals_scored
      t.integer :assists
      t.integer :clean_sheets
      t.integer :goals_conceded
      t.integer :own_goals
      t.integer :penalties_saved
      t.integer :penalties_missed
      t.integer :yellow_cards
      t.integer :red_cards
      t.integer :saves
      t.integer :bonus
      t.integer :bps
      t.decimal :creativity
      t.decimal :influence
      t.decimal :ict_index
      t.decimal :threat
      t.references :position, index: true
      t.references :team, index: true
      t.timestamps
    end
  end
end
