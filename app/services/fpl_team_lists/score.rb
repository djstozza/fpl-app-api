class FplTeamLists::Score < ApplicationService
  attr_reader :fpl_team_list, :list_positions

  def initialize(fpl_team_list)
    @fpl_team_list = fpl_team_list
    @list_positions = fpl_team_list.list_positions
  end

  def call
    process_substitutions

    fpl_team_list.update!(total_score: total_score)
  end

  private

  def process_substitutions
    no_minute_list_position_ids.each do |id|
      valid_substitute = ListPosition.find_by(id: valid_scoring_substitution_id(id))

      next unless valid_substitute

      role = valid_substitute.role

      ListPosition.find(id).update!(role: role)
      valid_substitute.update!(role: 'starting')
    end
  end

  def valid_scoring_substitution_id(list_position_id)
    SqlQuery.load(
      'list_positions/valid_scoring_substitution',
      list_positions: list_position_details,
      valid_substitutions: valid_substitutions(list_position_id),
    ).get('id')
  end

  def no_minute_list_position_ids
    SqlQuery
      .load('fpl_team_lists/no_minutes_list_positions', list_positions: list_position_details)
      .get('ids')
  end

  def valid_substitutions(list_position_id)
    SqlQuery
      .load('list_positions/valid_substitutions', list_position_id: list_position_id)
      .get('valid_substitutions')
      .to_a
      .compact
  end

  def list_position_details(excluded_player_ids = [])
    SqlQuery.load(
      'fpl_team_lists/list_position_details',
      fpl_team_list_id: fpl_team_list.id,
      excluded_player_ids: excluded_player_ids,
    )
  end

  def total_score
    list_position_details(list_positions.substitutes.pluck(:player_id))
      .results
      .sum { |result| result[:total_points] || 0 }
  end
end
