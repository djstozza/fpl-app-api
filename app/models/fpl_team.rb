# == Schema Information
#
# Table name: fpl_teams
#
#  id                     :bigint           not null, primary key
#  draft_pick_number      :integer
#  mini_draft_pick_number :integer
#  name                   :string           not null
#  rank                   :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  league_id              :bigint
#  owner_id               :bigint
#
# Indexes
#
#  index_fpl_teams_on_league_id  (league_id)
#  index_fpl_teams_on_owner_id   (owner_id)
#
class FplTeam < ApplicationRecord
  QUOTAS = {
    team: 3,
    goalkeepers: 2,
    midfielders: 5,
    defenders: 5,
    forwards: 3,
    players: 15,
  }.freeze

  belongs_to :owner, class_name: 'User', foreign_key: :owner_id
  belongs_to :league
  has_many :draft_picks
  has_and_belongs_to_many :players
  has_many :teams, through: :players
  has_many :fpl_team_lists

  alias_attribute :fpl_team_name, :name

  validates :name, :fpl_team_name, presence: true, uniqueness: { case_sensitive: false }
  validates :draft_pick_number,
            :mini_draft_pick_number,
            uniqueness: { scope: :league },
            allow_nil: true
end
