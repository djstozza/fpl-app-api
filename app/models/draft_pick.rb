# == Schema Information
#
# Table name: draft_picks
#
#  id          :bigint           not null, primary key
#  mini_draft  :boolean          default(FALSE), not null
#  pick_number :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  fpl_team_id :bigint
#  league_id   :bigint
#  player_id   :bigint
#
# Indexes
#
#  index_draft_picks_on_fpl_team_id                (fpl_team_id)
#  index_draft_picks_on_league_id                  (league_id)
#  index_draft_picks_on_pick_number_and_league_id  (pick_number,league_id) UNIQUE
#  index_draft_picks_on_player_id                  (player_id)
#  index_draft_picks_on_player_id_and_league_id    (player_id,league_id) UNIQUE
#
class DraftPick < ApplicationRecord
  belongs_to :player, optional: true
  belongs_to :fpl_team
  belongs_to :league
  delegate :owner, to: :fpl_team

  validates :player, uniqueness: { scope: :league }, allow_blank: true
  validates :pick_number, presence: true, uniqueness: { scope: :league }

  validate :player_pick_or_mini_draft, on: :update
  validate :fpl_team_in_league

  private

  def player_pick_or_mini_draft
    return if (player.present? && !mini_draft) || (player.blank? && mini_draft)

    errors.add(:base, 'Either select a player or a mini draft pick number')
  end

  def fpl_team_in_league
    return if fpl_team.league == league

    errors.add(:base, 'Fpl team must be in league')
  end
end
