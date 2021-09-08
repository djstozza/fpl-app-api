# == Schema Information
#
# Table name: leagues
#
#  id         :bigint           not null, primary key
#  active     :boolean          default(TRUE), not null
#  code       :string           not null
#  name       :string           not null
#  status     :integer          default("initialized"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  owner_id   :bigint
#
# Indexes
#
#  index_leagues_on_name      (name) UNIQUE
#  index_leagues_on_owner_id  (owner_id)
#
class League < ApplicationRecord
  CODE_LENGTH = 8
  MIN_FPL_TEAM_QUOTA = 7
  MAX_FPL_TEAM_QUOTA = 11

  # 15 player picks per team & 1 mini draft pick
  PICKS_PER_TEAM = FplTeam::QUOTAS[:players] + 1

  belongs_to :owner, class_name: 'User'
  has_many :fpl_teams
  has_many :players, through: :fpl_teams
  has_many :users, through: :fpl_teams, source: :owner
  has_many :fpl_team_lists, through: :fpl_teams
  has_many :mini_draft_picks
  has_many :waiver_picks, through: :fpl_team_lists
  has_many :draft_picks

  validates :name, presence: true, uniqueness: { case_sensitive: false, allow_nil: true }
  validates :code, presence: true, length: { is: CODE_LENGTH, allow_nil: true }

  enum status: {
    initialized: 0,
    draft_picks_generated: 1,
    draft: 2,
    live: 3,
  }

  def can_generate_draft_picks?
    fpl_teams.count >= MIN_FPL_TEAM_QUOTA && (initialized? || draft_picks_generated?)
  end

  def current_draft_pick
    draft_picks.order(:pick_number).find_by(player_id: nil, mini_draft: false)
  end

  def can_go_to_draft?
    draft? || live?
  end

  def can_go_to_mini_draft?
    Round.current.mini_draft
  end

  def incomplete_draft_picks?
    draft_picks.any? && draft_picks.where(mini_draft: false, player_id: nil).any?
  end
end
