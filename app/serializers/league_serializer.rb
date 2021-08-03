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
class LeagueSerializer < BaseSerializer
  ATTRS = %w[
    id
    name
  ].freeze

  def serializable_hash(*)
    attributes.slice(*ATTRS).tap do |attrs|
      attrs[:status] = status.humanize
      attrs[:show_draft_pick_column] = !initialized?
      attrs[:show_live_columns] = live?
      attrs[:can_go_to_draft] = can_go_to_draft?

      if current_user
        attrs[:is_owner] = owner?
        attrs[:owner] = serilized_owner
      end

      if owner?
        attrs[:code] = code
        attrs[:can_generate_draft_picks] = can_generate_draft_picks?
        attrs[:can_create_draft] = draft_picks_generated?
      end
    end
  end

  private

  def current_user
    @current_user ||= includes[:current_user]
  end

  def owner?
    owner == current_user
  end

  def serilized_owner
    UserSerializer.new(owner)
  end
end
