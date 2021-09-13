# == Schema Information
#
# Table name: fpl_teams
#
#  id                     :bigint           not null, primary key
#  draft_pick_number      :integer
#  mini_draft_pick_number :integer
#  name                   :citext           not null
#  rank                   :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  league_id              :bigint
#  owner_id               :bigint
#
# Indexes
#
#  index_fpl_teams_on_draft_pick_number_and_league_id       (draft_pick_number,league_id) UNIQUE
#  index_fpl_teams_on_league_id                             (league_id)
#  index_fpl_teams_on_mini_draft_pick_number_and_league_id  (mini_draft_pick_number,league_id) UNIQUE
#  index_fpl_teams_on_name                                  (name) UNIQUE
#  index_fpl_teams_on_owner_id                              (owner_id)
#
class FplTeamSerializer < BaseSerializer
  ATTRS = %w[
    id
    name
    rank
    draft_pick_number
    mini_draft_pick_number
  ].freeze

  def serializable_hash(*)
    attributes.slice(*ATTRS).tap do |attrs|
      attrs[:league] = serialized_league if includes[:league]
      attrs[:total_score] = total_score

      if includes[:current_user]
        attrs[:is_owner] = owner == includes[:current_user]
        attrs[:owner] = serialized_owner
      end
    end
  end

  private

  def serialized_league
    LeagueSerializer.new(league)
  end

  def serialized_owner
    UserSerializer.new(owner)
  end
end
