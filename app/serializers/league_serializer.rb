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
#  index_leagues_on_owner_id  (owner_id)
#
class LeagueSerializer < BaseSerializer
  ATTRS = %w[
    id
    name
    status
  ]

  def serializable_hash(*)
    attributes.slice(*ATTRS).tap do |attrs|
      if includes[:current_user]
        attrs[:is_owner] = owner == includes[:current_user]
        attrs[:owner] = UserSerializer.new(owner)
        attrs[:fpl_teams] = FplTeamSerializer.map(fpl_teams) if includes[:fpl_teams]
      end
    end
  end
end
