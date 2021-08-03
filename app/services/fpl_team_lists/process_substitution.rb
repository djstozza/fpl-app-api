# Process substitutions in the current fpl_team_list
class FplTeamLists::ProcessSubstitution < ApplicationService
  attr_reader :fpl_team_list,
              :user,
              :out_list_position_id,
              :out_list_position,
              :in_list_position_id,
              :in_list_position

  validate :user_can_substitute
  validate :valid_out_list_position
  validate :valid_in_list_position
  validate :valid_substitution

  def initialize(data, fpl_team_list, user)
    @fpl_team_list = fpl_team_list
    @out_list_position_id = data[:out_list_position_id]
    @in_list_position_id = data[:in_list_position_id]
    @user = user
  end

  def call
    return unless valid?

    out_role = out_list_position.role
    in_role = in_list_position.role

    update_list_position(in_list_position, out_role)
    update_list_position(out_list_position, in_role)
  end

  private

  def user_can_substitute
    return errors.add(:base, 'You are not authorised to perform this action') if fpl_team_list.owner != user
    return errors.add(:base, 'The team list is not from the current round') unless fpl_team_list.current?
    return unless Time.current > fpl_team_list.deadline_time

    errors.add(:base, 'The time for making substitutions has passed')
  end

  def valid_out_list_position
    @out_list_position = fpl_team_list.list_positions.find_by(id: out_list_position_id)

    errors.add(:base, 'Player being subbed out cannot be found') if @out_list_position.blank?
  end

  def valid_in_list_position
    @in_list_position = fpl_team_list.list_positions.find_by(id: in_list_position_id)

    errors.add(:base, 'Player being subbed in cannot be found') if @in_list_position.blank?
  end

  def valid_substitution
    return unless out_list_position.present? && in_list_position.present?
    return if valid_substitution_ids.include?(in_list_position_id.to_s)

    errors.add(:base, 'Invalid substitution')
  end

  def valid_substitution_ids
    SqlQuery.load(
      'list_positions/valid_substitutions',
      list_position_id: out_list_position_id,
    ).result[:valid_substitutions]
  end

  def update_list_position(list_position, role)
    list_position.update(role: role)
    errors.merge!(in_list_position.errors)
  end
end
