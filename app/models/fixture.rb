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
class Fixture < ApplicationRecord
  belongs_to :round
  belongs_to :home_team, class_name: 'Team', foreign_key: :team_h_id
  belongs_to :away_team, class_name: 'Team', foreign_key: :team_a_id

  validates :external_id, presence: true, uniqueness: true
end
