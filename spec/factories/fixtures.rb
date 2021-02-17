# == Schema Information
#
# Table name: fixtures
#
#  id                     :bigint           not null, primary key
#  code                   :integer
#  finished               :boolean
#  finished_provisional   :boolean
#  kickoff_time           :string
#  minutes                :integer
#  provisional_start_time :boolean
#  started                :boolean
#  stats                  :jsonb
#  team_a_difficulty      :integer
#  team_a_score           :integer
#  team_h_difficulty      :integer
#  team_h_score           :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  external_id            :integer
#  round_id               :bigint
#  team_a_id              :bigint
#  team_h_id              :bigint
#
# Indexes
#
#  index_fixtures_on_round_id   (round_id)
#  index_fixtures_on_team_a_id  (team_a_id)
#  index_fixtures_on_team_h_id  (team_h_id)
#
FactoryBot.define do
  factory :fixture do
    sequence :external_id do |n|
      n
    end

    sequence :code do |n|
      n
    end

    association :round, factory: :round
    association :away_team, factory: :team
    association :home_team, factory: :team
    team_h_difficulty { 4 }
    team_a_difficulty { 1 }
    kickoff_time { Time.now }
    started { true }
    finished { true }
  end
end
