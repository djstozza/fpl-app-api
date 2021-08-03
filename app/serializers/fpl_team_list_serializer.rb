# == Schema Information
#
# Table name: fpl_team_lists
#
#  id              :bigint           not null, primary key
#  cumulative_rank :integer
#  round_rank      :integer
#  total_score     :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  fpl_team_id     :bigint
#  round_id        :bigint
#
# Indexes
#
#  index_fpl_team_lists_on_fpl_team_id               (fpl_team_id)
#  index_fpl_team_lists_on_fpl_team_id_and_round_id  (fpl_team_id,round_id) UNIQUE
#  index_fpl_team_lists_on_round_id                  (round_id)
#
class FplTeamListSerializer < BaseSerializer
  ATTRS = %w[
    id
    cumulative_rank
    round_rank
    total_score
  ].freeze

  def serializable_hash(*)
    attributes.slice(*ATTRS).tap do |attrs|
      attrs[:round] = serialized_round
    end
  end

  private

  def serialized_round
    RoundSerializer.new(round)
  end
end
