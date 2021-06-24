# == Schema Information
#
# Table name: teams
#
#  id                    :bigint           not null, primary key
#  clean_sheets          :integer
#  code                  :integer
#  draws                 :integer
#  form                  :jsonb
#  goal_difference       :integer
#  goals_against         :integer
#  goals_for             :integer
#  losses                :integer
#  name                  :string
#  played                :integer
#  points                :integer
#  position              :integer
#  short_name            :string
#  strength              :integer
#  strength_attack_away  :integer
#  strength_attack_home  :integer
#  strength_defence_away :integer
#  strength_defence_home :integer
#  strength_overall_away :integer
#  strength_overall_home :integer
#  wins                  :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  external_id           :integer
#
class TeamSerializer < BaseSerializer
  ATTRS = %w[
    id
    name
    short_name
    position
    played
    points
    wins
    losses
    draws
    goals_for
    goals_against
    goal_difference
    clean_sheets
  ].freeze

  def serializable_hash(*)
    attributes.slice(*ATTRS).tap do |attrs|
      attrs[:current_form] = form&.last(5)
    end
  end
end
