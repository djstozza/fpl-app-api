# == Schema Information
#
# Table name: list_positions
#
#  id               :bigint           not null, primary key
#  role             :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  fpl_team_list_id :bigint
#  player_id        :bigint
#
# Indexes
#
#  index_list_positions_on_fpl_team_list_id                (fpl_team_list_id)
#  index_list_positions_on_player_id                       (player_id)
#  index_list_positions_on_player_id_and_fpl_team_list_id  (player_id,fpl_team_list_id) UNIQUE
#
class ListPosition < ApplicationRecord
  belongs_to :fpl_team_list
  belongs_to :player

  delegate :fpl_team, :round, to: :fpl_team_list
  delegate :league, to: :fpl_team
  delegate :position, to: :player

  enum role: { starting: 0, substitute_1: 1, substitute_2: 2, substitute_3: 3, substitute_gkp: 4 }

  validates :player_id, uniqueness: { scope: [:fpl_team_list_id] }
  validate :valid_substitutes
  validate :valid_substitute_gkp

  private

  def valid_substitutes
    return if starting? || substitute_gkp?
    return unless player.goalkeeper?

    errors.add(:base, 'A goalkeeper can only be selected as a substitute goalkeeper')
  end

  def valid_substitute_gkp
    return unless substitute_gkp?
    return if player.goalkeeper?

    errors.add(:base, 'Only a goalkeeper can be selected as a substitute goalkeeper')
  end
end
