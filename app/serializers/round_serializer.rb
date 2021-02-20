# == Schema Information
#
# Table name: rounds
#
#  id                        :bigint           not null, primary key
#  data_checked              :boolean
#  deadline_time             :string
#  deadline_time_epoch       :integer
#  deadline_time_game_offset :integer
#  finished                  :boolean
#  is_current                :boolean
#  is_next                   :boolean
#  is_previous               :boolean
#  name                      :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  external_id               :integer
#
class RoundSerializer < BaseSerializer
  ATTRS = %w[
    id
    name
    deadline_time
    finished
    data_checked
    is_previous
    is_current
    is_next
  ].freeze

  def serializable_hash(*)
    attributes.slice(*ATTRS).tap do |attrs|
      attrs[:fixtures] = serialized_fixtures if includes[:verbose]
    end
  end

  private

  def serialized_fixtures
    FixtureSerializer.map(
      fixtures.includes(
        :home_team,
        :away_team,
        home_team: :players
      )
    )
  end
end
