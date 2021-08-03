# == Schema Information
#
# Table name: mini_draft_picks
#
#  id            :bigint           not null, primary key
#  passed        :boolean          default(FALSE), not null
#  pick_number   :integer
#  season        :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  fpl_team_id   :bigint
#  in_player_id  :bigint
#  league_id     :bigint
#  out_player_id :bigint
#
# Indexes
#
#  index_mini_draft_picks_on_fpl_team_id                           (fpl_team_id)
#  index_mini_draft_picks_on_in_player_id                          (in_player_id)
#  index_mini_draft_picks_on_league_id                             (league_id)
#  index_mini_draft_picks_on_out_player_id                         (out_player_id)
#  index_mini_draft_picks_on_pick_number_and_league_id_and_season  (pick_number,league_id,season) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (in_player_id => players.id)
#  fk_rails_...  (out_player_id => players.id)
#
class MiniDraftPick < ApplicationRecord
  belongs_to :out_player, class_name: 'Player', optional: true
  belongs_to :in_player, class_name: 'Player', optional: true
  belongs_to :fpl_team
  belongs_to :league

  delegate :owner, to: :fpl_team

  validates :pick_number, :season, presence: true
  validates :pick_number, uniqueness: { scope: %i[league season] }
  validates :in_player, :out_player, presence: true, unless: :passed
  validates :in_player, :out_player, absence: true, if: :passed

  enum season: {
    summer: 0,
    winter: 1,
  }
end
