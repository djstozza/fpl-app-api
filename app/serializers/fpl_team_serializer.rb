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
class FplTeamSerializer < BaseSerializer
  ATTRS = %w[
    id
    name
  ]

  def serializable_hash(*)
    attributes.slice(*ATTRS).tap do |attrs|
      attrs[:league] = LeagueSerializer.new(league)
      if includes[:current_user]
        attrs[:is_owner] = owner == includes[:current_user]
        attrs[:owner] = UserSerializer.new(owner)
      end
    end
  end
end
