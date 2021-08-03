# == Schema Information
#
# Table name: waiver_picks
#
#  id               :bigint           not null, primary key
#  pick_number      :integer          not null
#  status           :integer          default("pending"), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  fpl_team_list_id :bigint
#  in_player_id     :bigint
#  out_player_id    :bigint
#
# Indexes
#
#  index_waiver_picks_on_fpl_team_list_id                  (fpl_team_list_id)
#  index_waiver_picks_on_in_player_id                      (in_player_id)
#  index_waiver_picks_on_out_player_id                     (out_player_id)
#  index_waiver_picks_on_pick_number_and_fpl_team_list_id  (pick_number,fpl_team_list_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (in_player_id => players.id)
#  fk_rails_...  (out_player_id => players.id)
#
class WaiverPick < ApplicationRecord
  belongs_to :fpl_team_list
  belongs_to :out_player, class_name: 'Player'
  belongs_to :in_player, class_name: 'Player'

  validates :status, :pick_number, presence: true
  validates :pick_number, uniqueness: { scope: :fpl_team_list_id }
  enum status: {
    pending: 0,
    approved: 1,
    declined: 2,
  }

  delegate :fpl_team, to: :fpl_team_list
  delegate :owner, to: :fpl_team
  delegate :current?,
           :waiver_deadline,
           to: :round
end
