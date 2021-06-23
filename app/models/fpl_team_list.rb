# == Schema Information
#
# Table name: fpl_team_lists
#
#  id              :bigint           not null, primary key
#  cumulative_rank :integer
#  round_rank      :integer
#  total_score     :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  fpl_team_id     :bigint
#  round_id        :bigint
#
# Indexes
#
#  index_fpl_team_lists_on_fpl_team_id               (fpl_team_id)
#  index_fpl_team_lists_on_fpl_team_id_and_round_id  (fpl_team_id,round_id) UNIQUE
#  index_fpl_team_lists_on_round_id                  (round_id)
#
class FplTeamList < ApplicationRecord
  belongs_to :round
  belongs_to :fpl_team

  has_many :list_positions
  has_many :players, through: :list_positions

  validates :round_id, uniqueness: { scope: [:fpl_team_id] }
end
