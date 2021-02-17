class CreateFixtures < ActiveRecord::Migration[6.0]
  def change
    create_table :fixtures do |t|
      t.string :kickoff_time
      t.integer :team_h_difficulty
      t.integer :team_a_difficulty
      t.integer :code
      t.integer :team_h_score
      t.integer :team_a_score
      t.integer :minutes
      t.boolean :started
      t.boolean :finished
      t.boolean :provisional_start_time
      t.boolean :finished_provisional
      t.jsonb :stats
      t.references :round, index: true
      t.references :team_h, references: :team, index: true
      t.references :team_a, references: :team, index: true
      t.integer :external_id
      t.timestamps
    end
  end
end
