# == Schema Information
#
# Table name: fixtures
#
#  id                     :bigint           not null, primary key
#  code                   :integer
#  finished               :boolean
#  finished_provisional   :boolean
#  kickoff_time           :string
#  minutes                :integer
#  provisional_start_time :boolean
#  started                :boolean
#  stats                  :jsonb
#  team_a_difficulty      :integer
#  team_a_score           :integer
#  team_h_difficulty      :integer
#  team_h_score           :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  external_id            :integer
#  round_id               :bigint
#  team_a_id              :bigint
#  team_h_id              :bigint
#
# Indexes
#
#  index_fixtures_on_round_id   (round_id)
#  index_fixtures_on_team_a_id  (team_a_id)
#  index_fixtures_on_team_h_id  (team_h_id)
#
class FixtureSerializer < BaseSerializer
  ATTRS = %w[
    id
    finished
    kickoff_time
    minutes
    started
    stats
    team_a_difficulty
    team_a_score
    team_h_difficulty
    team_h_score
  ].freeze

  def serializable_hash(*)
    attributes.slice(*ATTRS).tap do |attrs|
      attrs[:home_team] = serialized_home_team
      attrs[:away_team] = serialized_away_team
    end
  end

  private

  def serialized_home_team
    TeamSerializer.new(home_team, players: true)
  end

  def serialized_away_team
    TeamSerializer.new(away_team, players: true)
  end
end
