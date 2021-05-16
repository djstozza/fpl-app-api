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
  belongs_to :owner, class_name: 'User', foreign_key: :owner_id
  belongs_to :league

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :draft_pick_number,
            :mini_draft_pick_number,
            uniqueness: { scope: :league },
            allow_nil: true
end
